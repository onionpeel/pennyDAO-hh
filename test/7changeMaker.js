const { expect } = require('chai');

// const ChangeMakerABI = [
//   'function initialize(address _changeDao)',
//   'function x() returns (uint)'
// ];


describe('ChangeMaker.sol', () => {
  let changeMakerImplementation, cloneGenerator, clone;
  let changeMakerOwner, changeDaoOwner;

  describe('Signers', () => {
    it('Assigns signers', async () => {
      const accounts = await hre.ethers.getSigners();
      changeDaoOwner = accounts[0];
      expect(changeDaoOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      changeMakerOwner = accounts[1];
      expect(changeMakerOwner.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
      // organization2 = accounts[2];
      // expect(organization2.address).to.equal('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC');
    });
  });

  describe('Contract deployment', () => {
    it('Deploy ChangeMaker contract', async () => {
      const ChangeMaker = await hre.ethers.getContractFactory('ChangeMaker');
      let contract = await ChangeMaker.deploy();
      changeMakerImplementation = await contract.deployed();
      expect(changeMakerImplementation.address.length).to.equal(42);
    });

    it('Deploy CloneGenerator', async () => {
      const CloneGenerator = await hre.ethers.getContractFactory('CloneGenerator');
      let contract = await CloneGenerator.deploy();
      cloneGenerator = await contract.deployed();
      expect(cloneGenerator.address.length).to.equal(42);
    });

    it('Create clone', async () => {
      await cloneGenerator.createClone();
      cloneAddress = await cloneGenerator.clone();

      const { interface } = await ethers.getContractFactory('ChangeMaker');

      clone = new ethers.Contract(
        cloneAddress,
        interface,
        changeMakerOwner
      );

      console.log(cloneAddress)
      console.log(clone.address)
      let value = await clone.num();
      console.log(value.toString());

      await clone.setNum('8');
      value = await clone.num();
      console.log(value.toString());
    });
  });
});
// Test deployed contract and clones for address type.
