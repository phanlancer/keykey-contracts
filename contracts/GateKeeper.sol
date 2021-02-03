pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract GateKeeper is ERC20("GateKeeper", "xLOCK") {
    using SafeMath for uint256;
    IERC20 public lock;

    constructor(IERC20 _lock) public {
        lock = _lock;
    }

    // Enter the keeper. Pay some LOCKs. Earn some shares.
    function enter(uint256 _amount) public {
        uint256 totalLock = lock.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalLock == 0) {
            _mint(msg.sender, _amount);
        } else {
            uint256 what = _amount.mul(totalShares).div(totalLock);
            _mint(msg.sender, what);
        }
        lock.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the keeper. Claim back your LOCKs.
    function leave(uint256 _share) public {
        uint256 totalShares = totalSupply();
        uint256 what =
            _share.mul(lock.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        lock.transfer(msg.sender, what);
    }
}
