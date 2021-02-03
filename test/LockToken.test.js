const { expectRevert } = require("@openzeppelin/test-helpers");
const LockToken = artifacts.require("LockToken");

contract("LockToken", ([alice, bob, carol]) => {
  beforeEach(async () => {
    this.lock = await LockToken.new({ from: alice });
  });

  it("should have correct name and symbol and decimal", async () => {
    const name = await this.lock.name();
    const symbol = await this.lock.symbol();
    const decimals = await this.lock.decimals();
    assert.equal(name.valueOf(), "LockToken");
    assert.equal(symbol.valueOf(), "LOCK");
    assert.equal(decimals.valueOf(), "18");
  });

  it("should only allow owner to mint token", async () => {
    await this.lock.mint(alice, "100", { from: alice });
    await this.lock.mint(bob, "1000", { from: alice });
    await expectRevert(
      this.lock.mint(carol, "1000", { from: bob }),
      "Ownable: caller is not the owner"
    );
    const totalSupply = await this.lock.totalSupply();
    const aliceBal = await this.lock.balanceOf(alice);
    const bobBal = await this.lock.balanceOf(bob);
    const carolBal = await this.lock.balanceOf(carol);
    assert.equal(totalSupply.valueOf(), "1100");
    assert.equal(aliceBal.valueOf(), "100");
    assert.equal(bobBal.valueOf(), "1000");
    assert.equal(carolBal.valueOf(), "0");
  });

  it("should supply token transfers properly", async () => {
    await this.lock.mint(alice, "100", { from: alice });
    await this.lock.mint(bob, "1000", { from: alice });
    await this.lock.transfer(carol, "10", { from: alice });
    await this.lock.transfer(carol, "100", { from: bob });
    const totalSupply = await this.lock.totalSupply();
    const aliceBal = await this.lock.balanceOf(alice);
    const bobBal = await this.lock.balanceOf(bob);
    const carolBal = await this.lock.balanceOf(carol);
    assert.equal(totalSupply.valueOf(), "1100");
    assert.equal(aliceBal.valueOf(), "90");
    assert.equal(bobBal.valueOf(), "900");
    assert.equal(carolBal.valueOf(), "110");
  });

  it("should fail if you try to do bad transfers", async () => {
    await this.lock.mint(alice, "100", { from: alice });
    await expectRevert(
      this.lock.transfer(carol, "110", { from: alice }),
      "ERC20: transfer amount exceeds balance"
    );
    await expectRevert(
      this.lock.transfer(carol, "1", { from: bob }),
      "ERC20: transfer amount exceeds balance"
    );
  });
});
