pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LockToken.sol";

interface IMigratorMaster {
    // Perform LP token migration from legacy UniswapV2 to KeyKeySwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to UniswapV2 LP tokens.
    // KeyKeySwap must mint EXACTLY the same amount of KeyKeySwap LP tokens or
    // else something bad will happen. Traditional UniswapV2 does not
    // do that so be careful!
    function migrate(IERC20 token) external returns (IERC20);
}

// KeyMaster is the master of Key. He can make LOCK and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once LOCK is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract KeyMaster is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of LOCKs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accLockPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accLockPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. LOCKs to distribute per block.
        uint256 lastRewardBlock; // Last block number that LOCKs distribution occurs.
        uint256 accLockPerShare; // Accumulated LOCKs per share, times 1e12. See below.
    }

    // The LOCK TOKEN!
    LockToken public lock;
    // Dev address.
    address public devaddr;
    // Block number when bonus LOCK period ends.
    uint256 public bonusEndBlock;
    // LOCK tokens created per block.
    uint256 public lockPerBlock;
    // Bonus multiplier for early lock makers, times 1e12
    uint256 public constant BONUS_MULTIPLIER = 12000000000000;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorMaster public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when LOCK mining starts.
    uint256 public startBlock;
    // Number of blocks interval to halve the reward
    uint256 public halvingInterval;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        LockToken _lock,
        address _devaddr,
        uint256 _lockPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _halvingInterval
    ) public {
        lock = _lock;
        devaddr = _devaddr;
        lockPerBlock = _lockPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        halvingInterval = _halvingInterval;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accLockPerShare: 0
            })
        );
    }

    // Update the given pool's LOCK allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorMaster _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward halving multiplier over the given _from to _to block, assuming _from >= bonusEndBlock
    function _getHalvingMultiplier(uint256 _from, uint256 _to)
        private
        view
        returns (uint256)
    {
        uint256 fromTier = _from.sub(bonusEndBlock).div(halvingInterval);
        uint256 toTier = _to.sub(bonusEndBlock).div(halvingInterval);
        uint256 halving = 1e12;
        uint256 startCursorBlock = _from;
        uint256 endCursorBlock = _from;
        uint256 multiplier = 0;

        for (uint256 i = 0; i < fromTier; i++) {
            halving = halving.div(2);
        }

        for (uint256 i = fromTier; i <= toTier; i++) {
            if (i == toTier) {
                multiplier = multiplier.add(
                    _to.sub(endCursorBlock).mul(halving)
                );
            } else {
                endCursorBlock = bonusEndBlock.add(halvingInterval.mul(i + 1));
                multiplier = multiplier.add(
                    endCursorBlock.sub(startCursorBlock).mul(halving)
                );
                startCursorBlock = endCursorBlock;
                halving = halving.div(2);
            }
        }

        return multiplier;
    }

    // Return reward multiplier over the given _from to _to block, assuming _to > _from
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndBlock) {
            return _getHalvingMultiplier(_from, _to);
        } else {
            return
                bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
                    _getHalvingMultiplier(bonusEndBlock, _to)
                );
        }
    }

    // View function to see pending LOCKs on frontend.
    function pendingLock(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accLockPerShare = pool.accLockPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 lockReward =
                multiplier
                    .mul(lockPerBlock)
                    .mul(pool.allocPoint)
                    .div(totalAllocPoint)
                    .div(1e12);
            accLockPerShare = accLockPerShare.add(
                lockReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accLockPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 lockReward =
            multiplier
                .mul(lockPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint)
                .div(1e12);
        lock.mint(devaddr, lockReward.mul(8).div(100));
        lock.mint(address(this), lockReward);
        pool.accLockPerShare = pool.accLockPerShare.add(
            lockReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to KeyMaster for LOCK allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accLockPerShare).div(1e12).sub(
                    user.rewardDebt
                );
            safeLockTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accLockPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from KeyMaster.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accLockPerShare).div(1e12).sub(
                user.rewardDebt
            );
        safeLockTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accLockPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe lock transfer function, just in case if rounding error causes pool to not have enough LOCKs.
    function safeLockTransfer(address _to, uint256 _amount) internal {
        uint256 lockBal = lock.balanceOf(address(this));
        if (_amount > lockBal) {
            lock.transfer(_to, lockBal);
        } else {
            lock.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}
