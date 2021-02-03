const { expectRevert } = require("@openzeppelin/test-helpers");
const LockToken = artifacts.require("LockToken");
const GateKeeper = artifacts.require("GateKeeper");

contract("LockToken", ([alice, bob, carol]) => {
  beforeEach(async () => {
    this.lock = await LockToken.new({ from: alice });
    this.keeper = await GateKeeper.new(this.lock.address, { from: alice });
    this.lock.mint(alice, "100", { from: alice });
    this.lock.mint(bob, "100", { from: alice });
    this.lock.mint(carol, "100", { from: alice });
  });

  it("should not allow enter if not enough approve", async () => {
    await expectRevert(
      this.keeper.enter("100", { from: alice }),
      "ERC20: transfer amount exceeds allowance"
    );
    await this.lock.approve(this.keeper.address, "50", { from: alice });
    await expectRevert(
      this.keeper.enter("100", { from: alice }),
      "ERC20: transfer amount exceeds allowance"
    );
    await this.lock.approve(this.keeper.address, "100", { from: alice });
    await this.keeper.enter("100", { from: alice });
    assert.equal((await this.keeper.balanceOf(alice)).valueOf(), "100");
  });

  it("should not allow withraw more than what you have", async () => {
    await this.lock.approve(this.keeper.address, "100", { from: alice });
    await this.keeper.enter("100", { from: alice });
    await expectRevert(
      this.keeper.leave("200", { from: alice }),
      "ERC20: burn amount exceeds balance"
    );
  });

  it("should work with more than one participant", async () => {
    await this.lock.approve(this.keeper.address, "100", { from: alice });
    await this.lock.approve(this.keeper.address, "100", { from: bob });
    // Alice enters and gets 20 shares. Bob enters and gets 10 shares.
    await this.keeper.enter("20", { from: alice });
    await this.keeper.enter("10", { from: bob });
    assert.equal((await this.keeper.balanceOf(alice)).valueOf(), "20");
    assert.equal((await this.keeper.balanceOf(bob)).valueOf(), "10");
    assert.equal(
      (await this.lock.balanceOf(this.keeper.address)).valueOf(),
      "30"
    );
    // GateKeeper get 20 more LOCKs from an external source.
    await this.lock.transfer(this.keeper.address, "20", { from: carol });
    // Alice deposits 10 more LOCKs. She should receive 10*30/50 = 6 shares.
    await this.keeper.enter("10", { from: alice });
    assert.equal((await this.keeper.balanceOf(alice)).valueOf(), "26");
    assert.equal((await this.keeper.balanceOf(bob)).valueOf(), "10");
    // Bob withdraws 5 shares. He should receive 5*60/36 = 8 shares
    await this.keeper.leave("5", { from: bob });
    assert.equal((await this.keeper.balanceOf(alice)).valueOf(), "26");
    assert.equal((await this.keeper.balanceOf(bob)).valueOf(), "5");
    assert.equal(
      (await this.lock.balanceOf(this.keeper.address)).valueOf(),
      "52"
    );
    assert.equal((await this.lock.balanceOf(alice)).valueOf(), "70");
    assert.equal((await this.lock.balanceOf(bob)).valueOf(), "98");
  });
});
