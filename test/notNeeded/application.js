// const { expect } = require('chai');
//
// describe('Applications', () => {
//   let grantor, trustedForwarder, user3, applications;
//
//   it('Deploys contract and gets signers', async () => {
//     const accounts = await hre.ethers.getSigners();
//     grantor = accounts[0];
//     trustedForwarder = accounts[1];
//     user3 = accounts[2];
//
//     const Applications = await ethers.getContractFactory('Applications');
//     applications = await Applications.deploy(grantor.address, trustedForwarder.address);
//   });
//
//   it('createApplication()', async () => {
//     const DAI = '0x6b175474e89094c44da98b954eedeac495271d0f';
//     const applicationObj = {
//       awardToken: DAI,
//       recipient: user3.address,
//       awardAmount: 100,
//       ipfsMetadata: 'This is the metadata'
//     };
//
//     let tx = await applications.createApplication(applicationObj);
//     let txReceipt = await tx.wait(1);
//
//     for(let i = 0; i < txReceipt.events.length; i++) {
//       console.log(txReceipt.events[i].args);
//     };
//
//     // expect().to.equal();
//   });
//
//
// });
