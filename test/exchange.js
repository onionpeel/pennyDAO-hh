// const { expect } = require('chai');
//
// describe('Exchange', () => {
//   let bt, exchange, deployer, user1;
//
//
//
//   it('deploys contracts and assigns signers', async () => {
//     const accounts = await hre.ethers.getSigners();
//     deployer = accounts[0];
//     user1 = accounts[1];
//
//     Bt = await hre.ethers.getContractFactory('BasicToken');
//     bt = await Bt.deploy(ethers.BigNumber.from('10000'));
//
//     const Exchange = await hre.ethers.getContractFactory('Exchange');
//     exchange = await Exchange.deploy(bt.address);
//   });
//
//   it('Bt:transfer(): tranfers tokens', async () => {
//     await bt.connect(deployer).transfer(user1.address, ethers.BigNumber.from('7'));
//     let user1Balance = await bt.balanceOf(user1.address);
//     // console.log(user1Balance.toString());
//   });
// });
