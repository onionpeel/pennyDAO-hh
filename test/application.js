const { expect } = require('chai');

describe('Applications', () => {
  let user1, user2, user3, applications;

  it('Deploys contract and gets signers', async () => {
    const accounts = await hre.ethers.getSigners();
    user1 = accounts[0];
    user2 = accounts[1];
    user3 = accounts[2];

    const Applications = await ethers.getContractFactory('Applications');
    applications = await Applications.deploy(user1.address, user2.address);
  });

  it('createApplication()', async () => {
    const DAI = '0x6b175474e89094c44da98b954eedeac495271d0f';
    const applicationObj = {
      awardToken: DAI,
      recipient: user3.address,
      awardAmount: 100,
      ipfsMetadata: 'This is the metadata'
    };

    let tx = await applications.createApplication(applicationObj);
    let txReceipt = await tx.wait(1);
    console.log(txReceipt);
  });
});
