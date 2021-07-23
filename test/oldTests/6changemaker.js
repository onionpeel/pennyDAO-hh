// const { expect } = require('chai');
//
// xdescribe('ChangeMaker.sol', () => {
//   let changeMaker;
//   let changeMakerOwner;
//
//   it('Assigns signers', async () => {
//     const accounts = await hre.ethers.getSigners();
//     changeMakerOwner = accounts[0];
//     expect(changeMakerOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
//   });
//
//   describe('ChangeMaker contract deployment', () => {
//     it('Deploy contract', async () => {
//       const ChangeMaker = await hre.ethers.getContractFactory('ChangeMaker');
//       changeMaker = await ChangeMaker.deploy();
//       await changeMaker.deployed();
//       expect(changeMaker.address.length).to.equal(42);
//     });
//
//     it('Sets changeMakerOwner as contract owner', async () => {
//       await changeMaker.initialize(changeMakerOwner.address);
//       let owner = await changeMaker.owner();
//       expect(owner).to.equal(changeMakerOwner.address);
//     });
//   });
//
//   describe('', () => {
//
//   });
//
// });
