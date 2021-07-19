const { expect } = require('chai');

xdescribe('ChangeDAO.sol', () => {
  let changeDAO;
  let changeDAOOwner, organization1;

  it('Assigns signers', async () => {
    const accounts = await hre.ethers.getSigners();
    changeDAOOwner = accounts[0];
    expect(changeDAOOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
    organization1 = accounts[1];
    expect(organization1.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
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
  });

  describe('Approval', () => {
    it('checkChangeMakerApproval(): return false for non-approved changemakers', async () => {
      let approval = await changeDAO.checkChangeMakerApproval(organization1.address);
      expect(approval).to.equal(false);
    });

    it('approveNewChangeMaker(): Only changeDAO can grant changemaker approval', async () => {
      let org1Contract = changeDAO.connect(organization1);
      await expect(org1Contract.approveNewChangeMaker(organization1.address)).to.be.reverted;
    });

    it('approveNewChangeMaker(): changeDAOOwner approves organization1', async () =>{
      await changeDAO.approveNewChangeMaker(organization1.address);
      let approval = await changeDAO.checkChangeMakerApproval(organization1.address);
      expect(approval).to.equal(true);
    });

    it('removeApproval(): changeDAOOwner removes approval from organization1', async () => {
      await changeDAO.removeApproval(organization1.address);
      let approval = await changeDAO.checkChangeMakerApproval(organization1.address);
      expect(approval).to.equal(false);
    });
  });

  describe('Registration', () => {
    it('register(): register a new changemaker', async () => {
      await changeDAO.approveNewChangeMaker(organization1.address);
      let org1Contract = changeDAO.connect(organization1);
      await org1Contract.register();
      expect(await changeDAO.tokenId()).to.equal(1);
      expect(await changeDAO.ownerOf('1')).to.equal(organization1.address);
      let org1ProxyAddress = await changeDAO.tokenIdToChangeMakerContract('1');
      expect(org1ProxyAddress.length).to.equal(42);
    });
  });
});
