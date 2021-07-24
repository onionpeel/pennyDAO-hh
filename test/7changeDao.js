const { expect } = require('chai');

xdescribe('ChangeDao.sol', () => {
  let changeDao;
  let changeDaoOwner, organization1, organization2;

  describe('Signers', () => {
    it('Assigns signers', async () => {
      const accounts = await hre.ethers.getSigners();
      changeDaoOwner = accounts[0];
      expect(changeDaoOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      organization1 = accounts[1];
      expect(organization1.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
      organization2 = accounts[2];
      expect(organization2.address).to.equal('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC');
    });
  });

  describe('ChangeDao contract deployment', () => {
    it('Deploy contract', async () => {
      const ChangeDao = await hre.ethers.getContractFactory('ChangeDao');
      let contract = await ChangeDao.deploy();
      changeDao = await contract.deployed();
      expect(changeDao.address.length).to.equal(42);
    });

    it('Retrieves ERC721 name and symbol', async () => {
      expect(await changeDao.name()).to.equal('ChangeDAO');
      expect(await changeDao.symbol()).to.equal('CHNDv1IMPL');
    });

    it('changeDaoOwner is the contract owner', async () => {
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

    it('removeApproval(): only changeDaoOwner can remove approvals', async () => {
      let org2Contract = await changeDao.connect(organization2);
      await expect(org2Contract.removeApproval(organization1.address)).to.be.reverted;
    });

    it('removeApproval(): changeDaoOwner removes approval from organization1', async () => {
      await changeDao.removeApproval(organization1.address);
      let approval = await changeDao.approvedChangeMakers(organization1.address);
      expect(approval).to.equal(false);
    });
  });

  describe('Percentages', () => {
    it('Check initial percentages', async () => {
      expect(await changeDao.changeMakerPercentage()).to.equal(9800);
      expect(await changeDao.changeDaoPercentage()).to.equal(100);
    });

    it('getCommunityFundPercentage(): retrieves communityFund percentage', async () => {
      expect(await changeDao.getCommunityFundPercentage()).to.equal(100);
    });

    it('setPercentageDistributions(): only changeDao owner can call function', async () => {
      let org1Contract = changeDao.connect(organization1);
      await expect(org1Contract.setPercentageDistributions('9500', '200', '300'))
        .to.be.reverted;
    });

    it('setPercentageDistributions(): changeDaoOwner sets new percentages', async () => {
      await changeDao.setPercentageDistributions('9500', '200', '300');
      expect(await changeDao.changeMakerPercentage()).to.equal(9500);
      expect(await changeDao.changeDaoPercentage()).to.equal(200);
      expect(await changeDao.getCommunityFundPercentage()).to.equal(300);
    });
  });

  describe('Registration', () => {
    it('register(): only approved changeMaker can call function', async () => {
      let org1Contract = changeDao.connect(organization1);
      await expect(org1Contract.register())
        .to.be.reverted;
    });

    it('register(): registers a new changeMaker', async () => {
      await changeDao.approveNewChangeMaker(organization1.address);
      const org1Contract = changeDao.connect(organization1);

      await org1Contract.register();
      await org1Contract.register();
      await org1Contract.register();
      expect(await changeDao.changeMakerTokenId()).to.equal(3);
      expect(await changeDao.balanceOf(organization1.address)).to.equal(3);

      let clone1 = await changeDao.changeMakerClones(1);
      let clone2 = await changeDao.changeMakerClones(2);
      expect(clone1).to.not.equal(clone2);
      expect(clone1.length).to.equal(42);
      expect(clone2.length).to.equal(42);
    });
  });
});

// Test deployed contract and clones for address type.
