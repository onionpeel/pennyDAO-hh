const { expect } = require('chai');

describe('ChangeDao.sol', () => {
  let changeDao;
  let changeDaoOwner, organization1;

  describe('Signers', () => {
    it('Assigns signers', async () => {
      const accounts = await hre.ethers.getSigners();
      changeDaoOwner = accounts[0];
      expect(changeDaoOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      organization1 = accounts[1];
      expect(organization1.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
    });
  });

  describe('ChangeDao contract deployment', () => {
    it('Deploy contract', async () => {
      const ChangeDao = await hre.ethers.getContractFactory('ChangeDao');
      changeDao = await ChangeDao.deploy();
      await changeDao.deployed();
      expect(changeDao.address.length).to.equal(42);
    });

    it('Sets changeDaoOwner as contract owner', async () => {
      let contractOwner = await changeDao.owner();
      expect(contractOwner).to.equal(changeDaoOwner.address);
    });
  });

  describe('Approval', () => {
    it('approvedChangeMakers: return false for non-approved changemakers', async () => {
      let approval = await changeDao.approvedChangeMakers(organization1.address);
      expect(approval).to.equal(false);
    });

    it('approveNewChangeMaker(): Only changeDao can grant changemaker approval', async () => {
      let org1Contract = changeDao.connect(organization1);
      await expect(org1Contract.approveNewChangeMaker(organization1.address)).to.be.reverted;
    });

    it('approveNewChangeMaker(): changeDaoOwner approves organization1', async () =>{
      await changeDao.approveNewChangeMaker(organization1.address);
      let approval = await changeDao.approvedChangeMakers(organization1.address);
      expect(approval).to.equal(true);
    });

    it('removeApproval(): changeDaoOwner removes approval from organization1', async () => {
      await changeDao.removeApproval(organization1.address);
      let approval = await changeDao.approvedChangeMakers(organization1.address);
      expect(approval).to.equal(false);
    });
  });

});
