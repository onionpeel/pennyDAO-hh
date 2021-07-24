// const { expect } = require('chai');
//
// describe('ChangeDao.sol', () => {
//   let changeDao;
//   let changeDaoOwner, organization1, organization2;
//
//   describe('Signers', () => {
//     it('Assigns signers', async () => {
//       const accounts = await hre.ethers.getSigners();
//       changeDaoOwner = accounts[0];
//       expect(changeDaoOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
//       organization1 = accounts[1];
//       expect(organization1.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
//       organization2 = accounts[2];
//       expect(organization2.address).to.equal('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC');
//     });
//   });
//
//   describe('ChangeDao contract deployment', () => {
//     it('Deploy contract', async () => {
//       const ChangeDao = await hre.ethers.getContractFactory('Temp');
//       changeDao = await ChangeDao.deploy();
//       await changeDao.deployed();
//       expect(changeDao.address.length).to.equal(42);
//     });
//
//     it('Sets changeDaoOwner as contract owner', async () => {
//       expect(await changeDao.value()).to.equal(0);
//       await changeDao.setValue();
//       expect(await changeDao.value()).to.equal(10);
//     });
//   });
//
// });
