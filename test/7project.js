// const { expect } = require('chai');
//
// describe('Project.sol', () => {
//   // signers
//   let ChangeMaker; // ChangeMaker.sol instance that deploys Project.sol
//   let changeMaker; // an organization
//   // contracts
//   let project; // reference to the deployment of Project.sol
//   let projectClone; //changeMaker calls a function in project to create projectClone
//
//   describe('Signers', () => {
//     it('Assigns signers', async () => {
//       const accounts = await hre.ethers.getSigners();
//
//       ChangeMaker = accounts[0];
//       expect(ChangeMaker.address)
//         .to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
//
//       changeMaker = accounts[1];
//       expect(changeMaker.address)
//         .to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
//     });
//   });
//
//   describe('Contract deployment', () => {
//     // ChangeMaker.sol is the deployer
//     it('Deploy Project.sol', async () => {
//       const Project = await hre.ethers.getContractFactory('Project');
//       let contract = await Project.deploy();
//       project = await contract.deployed();
//       expect(project.address.length).to.equal(42);
//     });
//   });
//
//   describe('Clone', () => {
//     it('initialize()', async () => {
//
//
//   //     const cloneCreatorContract = prCloneGenerator.connect(cloneCreator);
//       // cloneCreate creates a new ChangeMaker clone with cloneCreator as the signer
//       // await cloneCreatorContract.createClone();
//       // cloneAddress = await cloneCreatorContract.clone();
//       // expect(cloneAddress.length).to.equal(42);
//   //
//   //     // changeMakerAddress = ChangeMaker.sol instance address
//   //     let changeMakerAddress = await cmCloneGenerator.changeMakerImplementation();
//   //     // cloneCreator creates a ChangeMaker clone instance
//   //     cloneAddress = await cloneCreatorContract.clone();
//   //
//   //     // ChangeMaker interface used for creating an instance of ChangeMaker
//   //     const { interface } = await ethers.getContractFactory('ChangeMaker');
//   //     // Contract object pointing to ChangeMaker instance
//   //     const changeMakerImplementation = new ethers.Contract(
//   //       changeMakerAddress,
//   //       interface,
//   //       cmCloneGeneratorDeployer
//   //     );
//   //     // Contract object pointing to ChangeMaker clone instance
//   //     clone = new ethers.Contract(cloneAddress, interface, cloneCreator);
//   //
//   //     /*The ChangeMaker instance was created by the cmCloneGenerator (= ChangeDao instance) contract instance.  This means that the owner is the cmCloneGenerator address.*/
//   //     let owner = await changeMakerImplementation.owner();
//   //     expect(owner).to.equal(cmCloneGenerator.address);
//   //
//   //     /* cloneCreator created the clone, but it does not have access the ChangeMaker's owner property because that is set in a constructor, which only happens when ChangeMaker is deployed */
//   //     let changeMakerOwner = await clone.owner();
//   //     expect(changeMakerOwner).to.equal('0x0000000000000000000000000000000000000000');
//     });
//   });
//
//   // //EOA
//   // let prCloneGeneratorDeployer, cloneCreator, nonCloneOwner;
//   // //Instances
//   // let prCloneGenerator, clone;
//   //
//   // describe('Signers', () => {
//   //   it('Assigns signers', async () => {
//   //     const accounts = await hre.ethers.getSigners();
//   //     /* prCloneGeneratorDeployer represents the ChangeDao.sol contract that creates the instance of ChangeMaker.sol */
//   //     prCloneGeneratorDeployer = accounts[0];
//   //     expect(prCloneGeneratorDeployer.address)
//   //       .to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
//   //     //cloneCreator = a changeMaker address that creates project clones
//   //     cloneCreator = accounts[1];
//   //     expect(cloneCreator.address)
//   //       .to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
//   //
//   //     nonCloneOwner = accounts[2];
//   //     expect(nonCloneOwner.address).to.equal('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC');
//   //   });
//   // });
//   //prCloneGenerator = ChangeMaker.sol
//   // describe('Contract deployment', () => {
//   //   it('Deploy PrCloneGenerator', async () => {
//   //     const PrCloneGenerator = await hre.ethers.getContractFactory('PrCloneGenerator');
//   //     let contract = await PrCloneGenerator.deploy();
//   //     prCloneGenerator = await contract.deployed();
//   //     expect(prCloneGenerator.address.length).to.equal(42);
//   //   });
//   // });
//
//   // describe('Clone', () => {
//   //   it('Create clone', async () => {
//   //     const cloneCreatorContract = prCloneGenerator.connect(cloneCreator);
//       // cloneCreate creates a new ChangeMaker clone with cloneCreator as the signer
//       // await cloneCreatorContract.createClone();
//       // cloneAddress = await cloneCreatorContract.clone();
//       // expect(cloneAddress.length).to.equal(42);
//   //
//   //     // changeMakerAddress = ChangeMaker.sol instance address
//   //     let changeMakerAddress = await cmCloneGenerator.changeMakerImplementation();
//   //     // cloneCreator creates a ChangeMaker clone instance
//   //     cloneAddress = await cloneCreatorContract.clone();
//   //
//   //     // ChangeMaker interface used for creating an instance of ChangeMaker
//   //     const { interface } = await ethers.getContractFactory('ChangeMaker');
//   //     // Contract object pointing to ChangeMaker instance
//   //     const changeMakerImplementation = new ethers.Contract(
//   //       changeMakerAddress,
//   //       interface,
//   //       cmCloneGeneratorDeployer
//   //     );
//   //     // Contract object pointing to ChangeMaker clone instance
//   //     clone = new ethers.Contract(cloneAddress, interface, cloneCreator);
//   //
//   //     /*The ChangeMaker instance was created by the cmCloneGenerator (= ChangeDao instance) contract instance.  This means that the owner is the cmCloneGenerator address.*/
//   //     let owner = await changeMakerImplementation.owner();
//   //     expect(owner).to.equal(cmCloneGenerator.address);
//   //
//   //     /* cloneCreator created the clone, but it does not have access the ChangeMaker's owner property because that is set in a constructor, which only happens when ChangeMaker is deployed */
//   //     let changeMakerOwner = await clone.owner();
//   //     expect(changeMakerOwner).to.equal('0x0000000000000000000000000000000000000000');
//   //   });
//   // });
//
//   // describe('Initialization', () => {
//   //   it('initialize(): sets values', async () => {
//   //     // The cloneCreator address is set as the cloneOwner via initialize()
//   //     let cloneOwner = await clone.cloneOwner();
//   //     expect(cloneOwner).to.equal(cloneCreator.address);
//   //     // The changeDao address that deployed the ChangeMaker instance
//   //     let cloneDeployer = await clone.changeDao();
//   //     expect(cloneDeployer).to.equal(cmCloneGenerator.address);
//   //   });
//   // });
//
//   // describe('Project', () => {
//   //   it('createProject(): only cloneOwner changeMaker can create new project', async () => {
//   //     const nonCloneOwnerContract = clone.connect(nonCloneOwner);
//   //
//   //     await expect(nonCloneOwnerContract.createProject(1000, 1000, 0))
//   //       .to.be.revertedWith('Only clone owner can create projects');
//   //   });
//   //
//   //   it('createProject(): cloneOwner changeMaker creates new project', async () => {
//   //     await clone.createProject(1000, 1000, 0);
//   //     await clone.createProject(2000, 6000, 100);
//   //     await clone.createProject(10000, 20000, 1000);
//   //
//   //     expect(await clone.projectTokenId()).to.equal(3);
//   //     expect(await clone.balanceOf(cloneCreator.address)).to.equal(3);
//   //
//   //     let clone1 = await clone.projectClones(1);
//   //     let clone2 = await clone.projectClones(2);
//   //     expect(clone1).to.not.equal(clone2);
//   //     expect(clone1.length).to.equal(42);
//   //     expect(clone2.length).to.equal(42);
//   //   });
//   // });
//
// });
