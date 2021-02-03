const { expectRevert, time } = require("@openzeppelin/test-helpers");
const ethers = require("ethers");
const LockToken = artifacts.require("LockToken");
const Timelock = artifacts.require("Timelock");

function encodeParameters(types, values) {
  const abi = new ethers.utils.AbiCoder();
  return abi.encode(types, values);
}

contract("Timelock", ([alice, bob, carol]) => {
  beforeEach(async () => {
    this.lock = await LockToken.new({ from: alice });
    this.timelock = await Timelock.new(bob, "259200", { from: alice });
    await this.lock.transferOwnership(this.timelock.address, { from: alice });
  });

  it("should not allow non-owner to do operation", async () => {
    await expectRevert(
      this.lock.transferOwnership(carol, { from: alice }),
      "Ownable: caller is not the owner"
    );
    await expectRevert(
      this.lock.transferOwnership(carol, { from: bob }),
      "Ownable: caller is not the owner"
    );
    await expectRevert(
      this.timelock.queueTransaction(
        this.lock.address,
        "0",
        "transferOwnership(address)",
        encodeParameters(["address"], [carol]),
        (await time.latest()).add(time.duration.days(4)),
        { from: alice }
      ),
      "Timelock::queueTransaction: Call must come from admin."
    );
  });

  it("should do the timelock thing", async () => {
    const eta = (await time.latest()).add(time.duration.days(4));
    await this.timelock.queueTransaction(
      this.lock.address,
      "0",
      "transferOwnership(address)",
      encodeParameters(["address"], [carol]),
      eta,
      { from: bob }
    );
    await time.increase(time.duration.days(1));
    await expectRevert(
      this.timelock.executeTransaction(
        this.lock.address,
        "0",
        "transferOwnership(address)",
        encodeParameters(["address"], [carol]),
        eta,
        { from: bob }
      ),
      "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
    );
    await time.increase(time.duration.days(4));
    await this.timelock.executeTransaction(
      this.lock.address,
      "0",
      "transferOwnership(address)",
      encodeParameters(["address"], [carol]),
      eta,
      { from: bob }
    );
    assert.equal((await this.lock.owner()).valueOf(), carol);
  });
});
