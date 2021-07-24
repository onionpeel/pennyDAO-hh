const { expect } = require('chai');

describe('ChangeMaker.sol', () => {
  // changeMakerImp
  let changeMakerImp, cloneGenerator, clone;
  /** changeMakerOwner represents the deployed instance of ChangeDao.sol that deploys the instance of ChangeMaker.sol
  **/
  let changeMakerOwner;

  describe('Signers', () => {
    it('Assigns signers', async () => {
      const accounts = await hre.ethers.getSigners();
      changeMakerOwner = accounts[0];
      expect(changeMakerOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
    });
  });

  describe('Contract deployment', () => {
    it('Deploy ChangeMaker contract', async () => {
      const ChangeMaker = await hre.ethers.getContractFactory('ChangeMaker');
      let contract = await ChangeMaker.deploy();
      changeMakerImp = await contract.deployed();
      expect(changeMakerImp.address.length).to.equal(42);
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
      expect(cloneAddress.length).to.equal(42);

      const { interface } = await ethers.getContractFactory('ChangeMaker');
      clone = new ethers.Contract(cloneAddress, interface, changeMakerOwner);
      expect(changeMakerImp.address).to.not.equal(cloneAddress);
    });

    describe('Initializaton', () => {
      it('initialize(): set changeDao address', async () => {
        await clone.initialize(changeMakerOwner.address);
        expect(await clone.changeDao()).to.equal(changeMakerOwner.address);
        
        /** The clone has set the changeDao variable, but the changeMakerImp never set this variable
        **/
        expect(await clone.changeDao()).to.not.equal(await changeMakerImp.changeDao());
      });
    });
  });
});
// Test deployed contract and clones for address type.
