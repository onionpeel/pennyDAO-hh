const { expect } = require('chai');

describe('Integration', () => {
  let changeDao;
  let org1ChangeDao;
  let changeMakerClone1;
  let changeMakerClone1Address;
  let changeMakerContract;
  let org2projectClone1;
  let cdProjectClone1;
  let org1projectClone1;
  // signers
  let changeDaoOwner, organization1, organization2, communityFund;

  describe('Signers', () => {
    it('Assigns signers', async () => {
      const accounts = await hre.ethers.getSigners();
      changeDaoOwner = accounts[0];
      expect(changeDaoOwner.address).to.equal('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
      organization1 = accounts[1];
      expect(organization1.address).to.equal('0x70997970C51812dc3A010C7d01b50e0d17dc79C8');
      organization2 = accounts[2];
      expect(organization2.address).to.equal('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC');
      communityFund = accounts[4];
      // expect(communityFund.address).to.equal();
    });
  });

  describe('ChangeDao contract deployment', () => {
    it('Deploy contract', async () => {
      const ChangeDao = await hre.ethers.getContractFactory('ChangeDao');
      let contract = await ChangeDao.deploy(communityFund.address);
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
      org1ChangeDao = changeDao.connect(organization1);
      await expect(org1ChangeDao.approveNewChangeMaker(organization1.address)).to.be.reverted;
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
      org1ChangeDao = changeDao.connect(organization1);
      await expect(org1ChangeDao.setPercentageDistributions('9500', '200', '300'))
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
      org1ChangeDao = changeDao.connect(organization1);
      await expect(org1ChangeDao.register())
        .to.be.reverted;
    });

    it('register(): registers a new changeMaker', async () => {
      await changeDao.approveNewChangeMaker(organization1.address);
      org1ChangeDao = changeDao.connect(organization1);


      // changeMaker.owner = changeDao
      let cmImp = await changeDao.changeMakerImplementation();
      const { interface } = await ethers.getContractFactory('ChangeMaker');
      changeMakerClone1 = new ethers.Contract(
        cmImp,
        interface,
        organization1
      );
      let owner = await changeMakerClone1.owner();
      console.log(owner)
      console.log(changeDao.address)


      await org1ChangeDao.register();
      await org1ChangeDao.register();
      await org1ChangeDao.register();
      expect(await changeDao.changeMakerTokenId()).to.equal(3);
      expect(await changeDao.balanceOf(organization1.address)).to.equal(3);

      changeMakerClone1Address = await changeDao.changeMakerClones(1);
      let changeMakerClone2Address = await changeDao.changeMakerClones(2);
      expect(changeMakerClone1Address).to.not.equal(changeMakerClone2Address);
      expect(changeMakerClone1Address.length).to.equal(42);
      expect(changeMakerClone2Address.length).to.equal(42);
    });
  });

  xdescribe('ChangeMaker clone', async () => {
    it('initialize(): organization1 cannot re-initialize clone', async () => {
      const { interface } = await ethers.getContractFactory('ChangeMaker');
      changeMakerClone1 = new ethers.Contract(
        changeMakerClone1Address,
        interface,
        organization1
      );

      await expect(changeMakerClone1.initialize(changeMakerClone1Address, changeDao.address))
        .to.be.reverted;
    });

    it('owner(): organization1 is the owner', async () => {
      // MUST REMOVE OWNABLE FROM CHANGEMAKER.SOL AND ADD CODE FOR SETTING OWNER
      // expect(await changeMakerClone1.owner()).to.equal(changeMakerClone1Address);
    });

    it('createProject(): only organization1 can create a new project', async () => {
      const { interface } = await ethers.getContractFactory('ChangeMaker');
      org2changeMakerClone1 = new ethers.Contract(
        changeMakerClone1Address,
        interface,
        organization2
      );

      await expect(org2changeMakerClone1.createProject(100, 200, 300)).to.be.reverted;
    });

    it('createProject(): organization1 creates a new project', async () => {
      // organization1 creates project clones
      await changeMakerClone1.createProject(100, 200, 300);
      await changeMakerClone1.createProject(400, 500, 600);
      await changeMakerClone1.createProject(700, 800, 900);

      expect(await changeMakerClone1.projectTokenId()).to.equal(3);
      expect(await changeMakerClone1.balanceOf(organization1.address)).to.equal(3);

      projectClone1Address = await changeMakerClone1.projectClones(1);
      let projectClone2Address = await changeMakerClone1.projectClones(2);
      expect(projectClone1Address).to.not.equal(projectClone2Address);
      expect(projectClone1Address.length).to.equal(42);
      expect(projectClone2Address.length).to.equal(42);
    });
  });



});
