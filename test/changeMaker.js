const { expect } = require('chai');

describe('ChangeMakers', () => {
  let changeMaker, deployer, user1, user2;

  it('deploys contracts and assigns signers', async () => {
    const accounts = await hre.ethers.getSigners();
    deployer = accounts[0];
    user1 = accounts[1];
    user2 = accounts[2];

    ChangeMakers = await hre.ethers.getContractFactory('ChangeMakers');
    changeMaker = await ChangeMakers.deploy();
  });

  it('ChangeMakers: owner()', async () => {
    const owner = await changeMaker.owner();
    expect(owner).to.equal(deployer.address);
  });

  it('ChangeMakers: ')

});
