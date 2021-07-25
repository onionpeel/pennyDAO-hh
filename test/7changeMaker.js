const { expect } = require('chai');

describe('ChangeMaker.sol', () => {
  //EOA
  let cloneGeneratorDeployer, cloneCreator;
  //Instances
  let cloneGenerator, clone;

  describe('Signers', () => {
    it('Assigns signers', async () => {
      const accounts = await hre.ethers.getSigners();
      cloneGeneratorDeployer = accounts[0];
      expect(cloneGeneratorDeployer.address)
        .to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');

      cloneCreator = accounts[1];
      expect(cloneCreator.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
    });
  });

  describe('Contract deployment', () => {
    it('Deploy CloneGenerator', async () => {
      const CloneGenerator = await hre.ethers.getContractFactory('CloneGenerator');
      let contract = await CloneGenerator.deploy();
      cloneGenerator = await contract.deployed();
      expect(cloneGenerator.address.length).to.equal(42);
    });
  });

  describe('Clone', () => {
    it('Create clone', async () => {
      const cloneCreatorContract = cloneGenerator.connect(cloneCreator);
      // cloneCreate creates a new ChangeMaker clone with cloneCreator as the signer
      await cloneCreatorContract.createClone();
      cloneAddress = await cloneCreatorContract.clone();
      expect(cloneAddress.length).to.equal(42);

      // changeMakerAddress = ChangeMaker.sol instance address
      let changeMakerAddress = await cloneGenerator.changeMakerImplementation();
      // cloneCreator creates a ChangeMaker clone instance
      clone = await cloneCreatorContract.clone();

      // ChangeMaker interface used for creating an instance of ChangeMaker
      const { interface } = await ethers.getContractFactory('ChangeMaker');
      // Contract object pointing to ChangeMaker instance
      const changeMakerImplementation = new ethers.Contract(
        changeMakerAddress,
        interface,
        cloneGeneratorDeployer
      );
      // Contract object pointing to ChangeMaker clone instance
      clone = new ethers.Contract(clone, interface, cloneCreator);

      /*The ChangeMaker instance was created by the cloneGenerator (= ChangeDao instance) contract instance.  This means that the owner is the cloneGenerator address.*/
      let owner = await changeMakerImplementation.owner();
      expect(owner).to.equal(cloneGenerator.address);

      /* cloneCreator created the clone, but it does not have access the ChangeMaker's owner property because that is set in a constructor, which only happens when ChangeMaker is deployed */
      let changeMakerOwner = await clone.owner();
      expect(changeMakerOwner).to.equal('0x0000000000000000000000000000000000000000');
    });
  });

  describe('Initialization', () => {
    it('initialize(): sets values', async () => {
      // The cloneCreator address is set as the cloneOwner via initialize()
      let cloneOwner = await clone.cloneOwner();
      expect(cloneOwner).to.equal(cloneCreator.address);
      // The changeDao address that deployed the ChangeMaker instance
      let cloneDeployer = await clone.changeDao();
      expect(cloneDeployer).to.equal(cloneGenerator.address);
    });
  });

  describe('Project', () => {
    it('createProject(): changeMaker creates new project', async () => {
      
    });
  });

});
