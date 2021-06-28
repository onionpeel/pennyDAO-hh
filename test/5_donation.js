const { expect } = require('chai');
const { upgrades } = require("hardhat");

describe('donation', () => {
  // contract instances
  let sponsors, changeMakers, changeMakers2, impactNFT_Generator, impactNFT_Generator2,
    projects, projects2, donation;
  let changeDAO, organization1, organization2, sponsor1, sponsor2, communityFund; //externally owned accounts
  let arrayOfDataForMintingNFTs; //data passed into Projects: createTokens()
  let daiContract, usdcContract;

  function expiresInOneHour() {
    const currentTimeinMill = Date.now();
    const currentTimeinSeconds = Math.floor(currentTimeinMill/1000);
    return currentTimeinSeconds + 3600;
  };

  it('Assigns signers', async () => {
    const accounts = await hre.ethers.getSigners();
    changeDAO = accounts[0];
    organization1 = accounts[1];
    sponsor1 = accounts[2];
    sponsor2 = accounts[4];
    organization2 = accounts[5];
    communityFund = accounts[6];
  });

  it('Sets arrayOfDataForMintingNFTs', async () => {
    arrayOfDataForMintingNFTs = [
      {
        sponsorAddress: sponsor1.address,
        sponsorTokenURI: "This is the URI for sponsor1's NFT"
      },
      {
        sponsorAddress: sponsor2.address,
        sponsorTokenURI: "This is the URI for sponsor2's NFT"
      }
    ];
  });

  it('Deploys ChangeMakers, ImpactNFT_Generator, Projects, Donation contracts', async () => {
      ChangeMakers = await hre.ethers.getContractFactory('ChangeMakers');
      changeMakers = await upgrades.deployProxy(
        ChangeMakers,
        [],
        { initializer: 'initialize' }
      );

      ImpactNFT_Generator = await hre.ethers.getContractFactory('ImpactNFT_Generator');
      impactNFT_Generator = await upgrades.deployProxy(
        ImpactNFT_Generator,
        ['Proof of Impact', 'IMPACT'],
        { initializer: 'initialize' }
      );

      const daiAddress = '0x6b175474e89094c44da98b954eedeac495271d0f';
      const usdcAddress = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';

      Projects = await hre.ethers.getContractFactory('Projects');
      projects = await upgrades.deployProxy(
          Projects,
          [changeMakers.address, impactNFT_Generator.address, daiAddress, usdcAddress],
          { initializer: 'initialize' }
      );

      daiContract = await ethers.getContractAt('IERC20', daiAddress);
      usdcContract = await ethers.getContractAt('IERC20', usdcAddress);

      Donation = await hre.ethers.getContractFactory('Donation');
      donation = await upgrades.deployProxy(
        Donation,
        [daiAddress, usdcAddress, changeDAO.address],
        { initializer: 'initialize' }
      );
  });

  it('ChangeMakers: becomeChangeMaker()', async () => {
    //check that changeDAO is the owner of the changeMakers contract
    let owner = await changeMakers.owner();
    expect(owner).to.equal(changeDAO.address);

    //ChangeDAO authorizes organization1.address to become a changeMaker
    await changeMakers.authorize(organization1.address);
    // Check the authorization status of organization1
    const isUser1Authorized = await changeMakers.checkAuthorization(organization1.address);
    expect(isUser1Authorized).to.equal(true);

    // organization1 registers as a new changeMaker
    await changeMakers.connect(organization1).becomeChangeMaker(
      "XYZ Charity", //name
    );
  });

  it('Projects: createProject(), getChangeMakerProjects()', async () => {
    //check that changeDAO is the owner of the projects contract
    let owner = await projects.owner();
    expect(owner).to.equal(changeDAO.address);
    //organization1 creates three new projects
    expirationTime = expiresInOneHour();
    await projects.connect(organization1).createProject(
      "XYZ first project", //name of project
      ethers.BigNumber.from(expirationTime), //time in seconds before expiration
      ethers.utils.parseEther('1000') //funding amount (1000*10e18);
    );
    expirationTime = expiresInOneHour();
    await projects.connect(organization1).createProject(
      "XYZ second project",
      ethers.BigNumber.from(expirationTime),
      ethers.utils.parseEther('1000')
    );
    expirationTime = expiresInOneHour();
    await projects.connect(organization1).createProject(
      "XYZ third project",
      ethers.BigNumber.from(expirationTime),
      ethers.utils.parseEther('1000')
    );
    //Return an array of all the project ids for the projects organization1 has created
    const XYZprojectArray = await projects
      .connect(changeDAO)
      .getChangeMakerProjects(organization1.address);
    expect(XYZprojectArray[0].toNumber()).to.equal(1);
    expect(XYZprojectArray[1].toNumber()).to.equal(2);
    expect(XYZprojectArray[2].toNumber()).to.equal(3);
  });

  it('sponsor1 acquires DAI', async () => {
    //impersonate externally owned account found on etherscan (this is Binance8)
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
    );
    let eoa = await ethers.provider.getSigner("0xf977814e90da44bfa03b6295a0616a897441acec");
    let daiContractComp = daiContract.connect(eoa);
    // transfer dai to sponsor1
    await daiContractComp.transfer(sponsor1.address, ethers.utils.parseEther('1000000'));
    let sponsor1Balance = await daiContractComp.balanceOf(sponsor1.address);
    expect(ethers.utils.formatEther(sponsor1Balance)).to.equal('1000000.0');
    // transfer dai to sponsor2
    await daiContractComp.transfer(sponsor2.address, ethers.utils.parseEther('1000000'));
    let sponsor2Balance = await daiContractComp.balanceOf(sponsor2.address);
    expect(ethers.utils.formatEther(sponsor2Balance)).to.equal('1000000.0');

    await hre.network.provider.request({
      method: "hardhat_stopImpersonatingAccount",
      params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
    );
  });

  it('Projects: sponsor1 funds a project with DAI and gets listed as a sponsor', async () => {
    let amount = ethers.utils.parseEther('700');

    projectsSponsor1 = projects.connect(sponsor1);
    daiContractSponsor1 = daiContract.connect(sponsor1);
    //sponsor1 gives approval for the instance of Project.sol to transferFrom() the approved amount
    await daiContractSponsor1.approve(projects.address, amount);
    await projectsSponsor1.fundProject(ethers.BigNumber.from(2), amount, "dai");

    let currentProjectFunding = await projectsSponsor1.currentProjectFunding(ethers.BigNumber.from(2));
    expect(ethers.utils.formatEther(currentProjectFunding)).to.equal(ethers.utils.formatEther(amount));

    let isFullyFunded = await projectsSponsor1.isProjectFullyFunded(ethers.BigNumber.from(2));
    expect(isFullyFunded).to.equal(false);
  });

  it('sponsor2 acquires USDC', async () => {
    //impersonate externally owned account found on etherscan
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x2b6f908bf9082ad39adb27c04e88adfec8f58110"]}
    );
    let eoa = await ethers.provider.getSigner("0x2b6f908bf9082ad39adb27c04e88adfec8f58110");
    let usdcContractComp = usdcContract.connect(eoa);

    // transfer USDC to sponsor2
    await usdcContractComp.transfer(sponsor2.address, ethers.utils.parseUnits('1000', 6));
    let sponsor2Balance = await usdcContractComp.balanceOf(sponsor2.address);
    expect(ethers.utils.formatUnits(sponsor2Balance, 6)).to.equal('1000.0');

    await hre.network.provider.request({
      method: "hardhat_stopImpersonatingAccount",
      params: ["0x2b6f908bf9082ad39adb27c04e88adfec8f58110"]}
    );
  });

  it('Projects: sponsor2 funds project with USDC; gets listed; project is fully funded', async () => {
    let amount = ethers.utils.parseUnits('300', 6);

    projectsSponsor2 = projects.connect(sponsor2);
    usdcContractSponsor2 = usdcContract.connect(sponsor2);
    //sponsor1 gives approval for the projects instance to transferFrom() the approved amount
    await usdcContractSponsor2.approve(projects.address, amount);
    await projectsSponsor2.fundProject(ethers.BigNumber.from(2), amount, "usdc");

    let currentProjectFunding = await projectsSponsor2.currentProjectFunding(ethers.BigNumber.from(2));
    expect(ethers.utils.formatEther(currentProjectFunding)).to.equal('1000.0');

    let isFullyFunded = await projectsSponsor2.isProjectFullyFunded(ethers.BigNumber.from(2));
    expect(isFullyFunded).to.equal(true);
  });

  it('Projects: sponsor1 and sponsor2 are listed as sponsors', async () => {
    let sponsorIds = await projects.getProjectSponsorIds(ethers.BigNumber.from(2));
    expect(sponsorIds[0].toNumber()).to.equal(1);
    expect(sponsorIds[1].toNumber()).to.equal(2);
  });

  it('Projects: organization1 has three project ids assigned to it', async () => {
    let organization1ProjectIds = await projects.getChangeMakerProjects(organization1.address);
    expect(organization1ProjectIds[0].toNumber()).to.equal(1);
    expect(organization1ProjectIds[1].toNumber()).to.equal(2);
    expect(organization1ProjectIds[2].toNumber()).to.equal(3);
  });

  it('Sponsors: sponsor1 and sponsor2 have project 2 in their list of sponsored projects', async () => {
    let sponsor1ProjectIds = await projects.getProjectsOfASponsor(sponsor1.address);
    let sponsor2ProjectIds = await projects.getProjectsOfASponsor(sponsor2.address);
    expect(sponsor1ProjectIds[0].toNumber()).to.equal(2);
    expect(sponsor1ProjectIds[0].toNumber()).to.equal(2);
  });

  it('Projects: ChangeDAO attempts to call createTokens but fails because not authorized', async () =>{
    expect(projects.createTokens(arrayOfDataForMintingNFTs, ethers.BigNumber.from(2))).to.be.revertedWith("Only the authorized changeMaker can call createTokens()");
  });

  it('Projects: authorized changeMaker successfully calls createTokens()', async () => {
    let organization1Project = projects.connect(organization1);
    let successfulCall = await organization1Project.createTokens(
      arrayOfDataForMintingNFTs,
      ethers.BigNumber.from(2)
    );

    let ownerNFT1 = await impactNFT_Generator.ownerOf(ethers.BigNumber.from(1));
    expect(ownerNFT1).to.equal(sponsor1.address);
    let ownerNFT2 = await impactNFT_Generator.ownerOf(ethers.BigNumber.from(2));
    expect(ownerNFT2).to.equal(sponsor2.address);
  });

  it('Projects: changeMaker calls withdrawChangemakerShare() and gets set percentage of funding',
    async () => {
      let organization1Project = projects.connect(organization1);
      //changeMaker calls function to receive project funding (currently based on 98%)
      await organization1Project.withdrawChangemakerShare(ethers.BigNumber.from('2'));
      let organization1DaiBalance = await daiContract.balanceOf(organization1.address);
      // console.log(ethers.utils.formatEther(organization1DaiBalance))
      expect(ethers.utils.formatEther(organization1DaiBalance)).to.equal('686.0');
      let organization1UsdcBalance = await usdcContract.balanceOf(organization1.address);
      // console.log(ethers.utils.formatUnits(organization1UsdcBalance, 6))
      expect(ethers.utils.formatUnits(organization1UsdcBalance, 6)).to.equal('294.0');
  });

  it('Projects: ChangeDAO calls withdrawChangeDaoShare() and gets set percentage of funding',
    async () => {
      let changeDAOProject = projects.connect(changeDAO);
      //changeDAO calls function to receive project funding (currently based on 1%)
      await changeDAOProject.withdrawChangeDaoShare(ethers.BigNumber.from('2'));
      let changeDAODaiBalance = await daiContract.balanceOf(changeDAO.address);
      // console.log(ethers.utils.formatEther(changeDAODaiBalance))
      expect(ethers.utils.formatEther(changeDAODaiBalance)).to.equal('7.0');
      let changeDAOUsdcBalance = await usdcContract.balanceOf(changeDAO.address);
      // console.log(ethers.utils.formatUnits(changeDAOUsdcBalance, 6))
      expect(ethers.utils.formatUnits(changeDAOUsdcBalance, 6)).to.equal('3.0');

      // let projectsDaiBalance = await daiContract.balanceOf(projects.address);
      // console.log(ethers.utils.formatEther(projectsDaiBalance));
  });

  it('Projects: ChangeDAO calls withdrawCommunityFundShare() and gets set percentage of funding',
    async () => {
      let communityFundProject = projects.connect(communityFund);
      //communityFund calls function to receive project funding (currently based on 1%)
      await communityFundProject.withdrawCommunityFundShare(ethers.BigNumber.from('2'));
      let communityFundDaiBalance = await daiContract.balanceOf(communityFund.address);
      // console.log(ethers.utils.formatEther(communityFundDaiBalance))
      expect(ethers.utils.formatEther(communityFundDaiBalance)).to.equal('7.0');
      let communityFundUsdcBalance = await usdcContract.balanceOf(communityFund.address);
      // console.log(ethers.utils.formatUnits(communityFundUsdcBalance, 6))
      expect(ethers.utils.formatUnits(communityFundUsdcBalance, 6)).to.equal('3.0');

      let projectsDaiBalance = await daiContract.balanceOf(projects.address);
      // console.log(ethers.utils.formatEther(projectsDaiBalance));
      expect(ethers.utils.formatEther(projectsDaiBalance)).to.equal('0.0');

      let projectsUsdcBalance = await usdcContract.balanceOf(projects.address);
      // console.log(ethers.utils.formatUnits(projectsUsdcBalance, 6));
      expect(ethers.utils.formatUnits(projectsUsdcBalance, 6)).to.equal('0.0');
  });

  it('Donation: Send Ether to contract', async () => {
    let donationBalance = await ethers.provider.getBalance(donation.address);
    // console.log(ethers.utils.formatEther(donationBalance));
    expect(ethers.utils.formatEther(donationBalance)).to.equal('0.0');
    //impersonate externally owned account found on etherscan (this is Binance8)
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
    );
    let eoa = await ethers.provider.getSigner("0xf977814e90da44bfa03b6295a0616a897441acec");
    await eoa.sendTransaction({
      to: donation.address,
      value: ethers.utils.parseEther('3.0')
    });

    donationBalance = await ethers.provider.getBalance(donation.address);
    // console.log(ethers.utils.formatEther(donationBalance));
    expect(ethers.utils.formatEther(donationBalance)).to.equal('3.0');

    await hre.network.provider.request({
      method: "hardhat_stopImpersonatingAccount",
      params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
    );
  });

  it('Donation: ChangeDAO withdraws ETH from contract', async () => {
    let changeDAODonation = donation.connect(changeDAO);
    await changeDAODonation.withdrawETH();

    let donationBalance = await ethers.provider.getBalance(donation.address);
    // console.log(ethers.utils.formatEther(donationBalance));
    expect(ethers.utils.formatEther(donationBalance)).to.equal('0.0');

    let changeDAOBalance = await ethers.provider.getBalance(changeDAO.address);
    // console.log(ethers.utils.formatEther(changeDAOBalance));
    //This test needs to account for the gas cost that changeDAO pays.  The final value will be 3.0 - gas cost
    // expect(ethers.utils.formatEther(changeDAOBalance)).to.equal('3.0');
  });

  it('Donation: donate DAI with donateStablecoins()', async () => {
    let amount = ethers.utils.parseEther('1000');

    //impersonate externally owned account found on etherscan (this is Binance8)
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
    );
    let eoa = await ethers.provider.getSigner("0xf977814e90da44bfa03b6295a0616a897441acec");

    let daiContractInstance = daiContract.connect(eoa);
    let eoaDoncation = donation.connect(eoa);

    await daiContractInstance.approve(donation.address, amount);
    //eoa donates DAI to Donation.sol
    await eoaDoncation.donateStablecoins("dai", amount);

    let donationBalance = await daiContract.balanceOf(donation.address);
    // console.log(ethers.utils.formatEther(donationBalance));
    expect(ethers.utils.formatEther(donationBalance)).to.equal('1000.0');

    await hre.network.provider.request({
      method: "hardhat_stopImpersonatingAccount",
      params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
    );
  });

  it('Donation: donate USDC with donateStablecoins()', async () => {
    let amount = ethers.utils.parseUnits('1000', 6);

    //impersonate externally owned account found on etherscan
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x2b6f908bf9082ad39adb27c04e88adfec8f58110"]}
    );

    let eoa = await ethers.provider.getSigner("0x2b6f908bf9082ad39adb27c04e88adfec8f58110");

    let usdcContractInstance = usdcContract.connect(eoa);
    let eoaDoncation = donation.connect(eoa);

    await usdcContractInstance.approve(donation.address, amount);
    //eoa donates DAI to Donation.sol
    await eoaDoncation.donateStablecoins("usdc", amount);

    let donationBalance = await usdcContract.balanceOf(donation.address);
    // console.log(ethers.utils.formatUnits(donationBalance, 6));
    expect(ethers.utils.formatUnits(donationBalance, 6)).to.equal('1000.0');

    await hre.network.provider.request({
      method: "hardhat_stopImpersonatingAccount",
      params: ["0x2b6f908bf9082ad39adb27c04e88adfec8f58110"]}
    );
  });

  it('Donation: changeDAO withdraws all stablecoins with withdrawStablecoins()', async () => {
    let changeDAODonation = donation.connect(changeDAO);
    await changeDAODonation.withdrawStablecoins();

    let changeDAODaiBalance = await daiContract.balanceOf(changeDAO.address);
    // console.log(ethers.utils.formatEther(changeDAODaiBalance));
    expect(ethers.utils.formatEther(changeDAODaiBalance)).to.equal('1007.0');

    let changeDAOUsdcBalance = await usdcContract.balanceOf(changeDAO.address);
    // console.log(ethers.utils.formatUnits(changeDAOUsdcBalance, 6));
    expect(ethers.utils.formatUnits(changeDAOUsdcBalance, 6)).to.equal('1003.0');
  });
});
