const { expect } = require('chai');

describe('ChangeMaker.sol', () => {
  //EOA
  let cmCloneGeneratorDeployer, cloneCreator, nonCloneOwner;
  //Instances
  let cmCloneGenerator, clone;

  describe('Signers', () => {
    it('Assigns signers', async () => {
      const accounts = await hre.ethers.getSigners();
      //CMcloneGeneratorDeployer = EOA that deploys ChangeDao.sol
      cmCloneGeneratorDeployer = accounts[0];
      expect(cmCloneGeneratorDeployer.address)
        .to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      //cloneCreator = EOA that has been approved as a changeMaker
      cloneCreator = accounts[1];
      expect(cloneCreator.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');

      nonCloneOwner = accounts[2];
      expect(nonCloneOwner.address).to.equal('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC');
    });
  });

  describe('Contract deployment', () => {
    it('Deploy CMCloneGenerator', async () => {
      const CMCloneGenerator = await hre.ethers.getContractFactory('CMCloneGenerator');
      // let contract = await CMCloneGenerator.deploy();
      // cmCloneGenerator = await contract.deployed();
      // expect(cmCloneGenerator.address.length).to.equal(42);
    });
  });
  //
  // describe('Clone', () => {
  //   it('Create clone', async () => {
  //     const cloneCreatorContract = cmCloneGenerator.connect(cloneCreator);
  //     // cloneCreate creates a new ChangeMaker clone with cloneCreator as the signer
  //     await cloneCreatorContract.createClone();
  //     cloneAddress = await cloneCreatorContract.clone();
  //     expect(cloneAddress.length).to.equal(42);
  //
  //     // changeMakerAddress = ChangeMaker.sol instance address
  //     let changeMakerAddress = await cmCloneGenerator.changeMakerImplementation();
  //     // cloneCreator creates a ChangeMaker clone instance
  //     cloneAddress = await cloneCreatorContract.clone();
  //
  //     // ChangeMaker interface used for creating an instance of ChangeMaker
  //     const { interface } = await ethers.getContractFactory('ChangeMaker');
  //     // Contract object pointing to ChangeMaker instance
  //     const changeMakerImplementation = new ethers.Contract(
  //       changeMakerAddress,
  //       interface,
  //       cmCloneGeneratorDeployer
  //     );
  //     // Contract object pointing to ChangeMaker clone instance
  //     clone = new ethers.Contract(cloneAddress, interface, cloneCreator);
  //
  //     /*The ChangeMaker instance was created by the cmCloneGenerator (= ChangeDao instance) contract instance.  This means that the owner is the cmCloneGenerator address.*/
  //     let owner = await changeMakerImplementation.owner();
  //     expect(owner).to.equal(cmCloneGenerator.address);
  //
  //     /* cloneCreator created the clone, but it does not have access the ChangeMaker's owner property because that is set in a constructor, which only happens when ChangeMaker is deployed */
  //     let changeMakerOwner = await clone.owner();
  //     expect(changeMakerOwner).to.equal('0x0000000000000000000000000000000000000000');
  //   });
  // });
  //
  // describe('Initialization', () => {
  //   it('initialize(): sets values', async () => {
  //     // The cloneCreator address is set as the cloneOwner via initialize()
  //     let cloneOwner = await clone.cloneOwner();
  //     expect(cloneOwner).to.equal(cloneCreator.address);
  //     // The changeDao address that deployed the ChangeMaker instance
  //     let cloneDeployer = await clone.changeDao();
  //     expect(cloneDeployer).to.equal(cmCloneGenerator.address);
  //   });
  // });
  //
  // describe('Project', () => {
  //   it('createProject(): only cloneOwner changeMaker can create new project', async () => {
  //     const nonCloneOwnerContract = clone.connect(nonCloneOwner);
  //
  //     await expect(nonCloneOwnerContract.createProject(1000, 1000, 0))
  //       .to.be.revertedWith('Only clone owner can create projects');
  //   });
  //
  //   it('createProject(): cloneOwner changeMaker creates new project', async () => {
  //     await clone.createProject(1000, 1000, 0);
  //     await clone.createProject(2000, 6000, 100);
  //     await clone.createProject(10000, 20000, 1000);
  //
  //     expect(await clone.projectTokenId()).to.equal(3);
  //     expect(await clone.balanceOf(cloneCreator.address)).to.equal(3);
  //
  //     let clone1 = await clone.projectClones(1);
  //     let clone2 = await clone.projectClones(2);
  //     expect(clone1).to.not.equal(clone2);
  //     expect(clone1.length).to.equal(42);
  //     expect(clone2.length).to.equal(42);
  //   });
  // });

});
