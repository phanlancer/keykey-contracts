const LockToken = artifacts.require("LockToken");
const LockSmith = artifacts.require("LockSmith");
const MockERC20 = artifacts.require("MockERC20");
const UniswapV2Pair = artifacts.require("UniswapV2Pair");
const UniswapV2Factory = artifacts.require("UniswapV2Factory");

contract("LockSmith", ([alice, keeper, minter]) => {
  beforeEach(async () => {
    this.factory = await UniswapV2Factory.new(alice, { from: alice });
    this.lock = await LockToken.new({ from: alice });
    await this.lock.mint(minter, "100000000", { from: alice });
    this.weth = await MockERC20.new("WETH", "WETH", "100000000", {
      from: minter,
    });
    this.token1 = await MockERC20.new("TOKEN1", "TOKEN", "100000000", {
      from: minter,
    });
    this.token2 = await MockERC20.new("TOKEN2", "TOKEN2", "100000000", {
      from: minter,
    });
    this.smith = await LockSmith.new(
      this.factory.address,
      keeper,
      this.lock.address,
      this.weth.address
    );
    this.lockWETH = await UniswapV2Pair.at(
      (await this.factory.createPair(this.weth.address, this.lock.address))
        .logs[0].args.pair
    );
    this.wethToken1 = await UniswapV2Pair.at(
      (await this.factory.createPair(this.weth.address, this.token1.address))
        .logs[0].args.pair
    );
    this.wethToken2 = await UniswapV2Pair.at(
      (await this.factory.createPair(this.weth.address, this.token2.address))
        .logs[0].args.pair
    );
    this.token1Token2 = await UniswapV2Pair.at(
      (await this.factory.createPair(this.token1.address, this.token2.address))
        .logs[0].args.pair
    );
  });

  it("should make LOCKs successfully", async () => {
    await this.factory.setFeeTo(this.smith.address, { from: alice });
    await this.weth.transfer(this.lockWETH.address, "10000000", {
      from: minter,
    });
    await this.lock.transfer(this.lockWETH.address, "10000000", {
      from: minter,
    });
    await this.lockWETH.mint(minter);
    await this.weth.transfer(this.wethToken1.address, "10000000", {
      from: minter,
    });
    await this.token1.transfer(this.wethToken1.address, "10000000", {
      from: minter,
    });
    await this.wethToken1.mint(minter);
    await this.weth.transfer(this.wethToken2.address, "10000000", {
      from: minter,
    });
    await this.token2.transfer(this.wethToken2.address, "10000000", {
      from: minter,
    });
    await this.wethToken2.mint(minter);
    await this.token1.transfer(this.token1Token2.address, "10000000", {
      from: minter,
    });
    await this.token2.transfer(this.token1Token2.address, "10000000", {
      from: minter,
    });
    await this.token1Token2.mint(minter);
    // Fake some revenue
    await this.token1.transfer(this.token1Token2.address, "100000", {
      from: minter,
    });
    await this.token2.transfer(this.token1Token2.address, "100000", {
      from: minter,
    });
    await this.token1Token2.sync();
    await this.token1.transfer(this.token1Token2.address, "10000000", {
      from: minter,
    });
    await this.token2.transfer(this.token1Token2.address, "10000000", {
      from: minter,
    });
    await this.token1Token2.mint(minter);
    // smith should have the LP now
    assert.equal(
      (await this.token1Token2.balanceOf(this.smith.address)).valueOf(),
      "16528"
    );
    // After calling convert, keeper should have LOCK value at ~1/6 of revenue
    await this.smith.convert(this.token1.address, this.token2.address);
    assert.equal((await this.lock.balanceOf(keeper)).valueOf(), "32965");
    assert.equal(
      (await this.token1Token2.balanceOf(this.smith.address)).valueOf(),
      "0"
    );
    // Should also work for LOCK-ETH pair
    await this.lock.transfer(this.lockWETH.address, "100000", {
      from: minter,
    });
    await this.weth.transfer(this.lockWETH.address, "100000", {
      from: minter,
    });
    await this.lockWETH.sync();
    await this.lock.transfer(this.lockWETH.address, "10000000", {
      from: minter,
    });
    await this.weth.transfer(this.lockWETH.address, "10000000", {
      from: minter,
    });
    await this.lockWETH.mint(minter);
    assert.equal(
      (await this.lockWETH.balanceOf(this.smith.address)).valueOf(),
      "16537"
    );
    await this.smith.convert(this.lock.address, this.weth.address);
    assert.equal((await this.lock.balanceOf(keeper)).valueOf(), "66249");
    assert.equal(
      (await this.lockWETH.balanceOf(this.smith.address)).valueOf(),
      "0"
    );
  });
});
