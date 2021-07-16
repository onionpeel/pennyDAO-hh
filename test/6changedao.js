const { expect } = require('chai');

describe('ChangeDAO.sol', () => {
  let changeDAO;
  let changeDAOOwner, organization1, organization2;

  it('Assigns signers', async () => {
    const accounts = await hre.ethers.getSigners();
    changeDAOOwner = accounts[0];
    expect(changeDAOOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
  });

  describe('ChangeDAO contract deployment', () => {
    it('Deploy contract', async () => {
      const ChangeDAO = await hre.ethers.getContractFactory('ChangeDAO');
      changeDAO = await ChangeDAO.deploy();
      await changeDAO.deployed();
      expect(changeDAO.address.length).to.equal(42);
    });

    it('Sets changeDAOOwner as contract owner', async () => {
      let contractOwner = await changeDAO.owner();
      expect(contractOwner).to.equal(changeDAOOwner.address);
    });

    describe('Approval', () => {
      
    });
  });



});
