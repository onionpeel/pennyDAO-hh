const { expect } = require('chai');
const { upgrades } = require("hardhat");

xdescribe('stablecoins_refund', () => {
  // contract instances
  let sponsors, changeMakers, changeMakers2, impactNFT_Generator, impactNFT_Generator2,
    projects, projects2;
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

  it('Deploys ChangeMakers, ImpactNFT_Generator, Projects contracts', async () => {
      ChangeMakers = await hre.ethers.getContractFactory('ChangeMakers');
      changeMakers = await upgrades.deployProxy(
        ChangeMakers,
        [],
        { initializer: 'initialize'}
      );

      ImpactNFT_Generator = await hre.ethers.getContractFactory('ImpactNFT_Generator');
      impactNFT_Generator = await upgrades.deployProxy(
        ImpactNFT_Generator,
        ['Proof of Impact', 'IMPACT'],
        { initializer: 'initialize'}
      );

      const daiAddress = '0x6b175474e89094c44da98b954eedeac495271d0f';
      const usdcAddress = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';

      Projects = await hre.ethers.getContractFactory('Projects');
      projects = await upgrades.deployProxy(
          Projects,
          [changeMakers.address, impactNFT_Generator.address, daiAddress, usdcAddress],
          { initializer: 'initialize'}
      );

      daiContract = await ethers.getContractAt('IERC20', daiAddress);
      usdcContract = await ethers.getContractAt('IERC20', usdcAddress);
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
      params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
    );
  });

  it('Projects: sponsor2 funds project with USDC; gets listed; project is NOT fully funded', async () => {
    let amount = ethers.utils.parseUnits('200', 6);

    projectsSponsor2 = projects.connect(sponsor2);
    usdcContractSponsor2 = usdcContract.connect(sponsor2);
    //sponsor1 gives approval for the projects instance to transferFrom() the approved amount
    await usdcContractSponsor2.approve(projects.address, amount);
    await projectsSponsor2.fundProject(ethers.BigNumber.from(2), amount, "usdc");

    let currentProjectFunding = await projectsSponsor2.currentProjectFunding(ethers.BigNumber.from(2));
    expect(ethers.utils.formatEther(currentProjectFunding)).to.equal('900.0');

    let isFullyFunded = await projectsSponsor2.isProjectFullyFunded(ethers.BigNumber.from(2));
    expect(isFullyFunded).to.equal(false);
  });

  it('Projects: ChangeDAO calls returnFundsToAllSponsors()', async () => {
    //sponsor1 balance before refund
    let sponsor1DaiBalance = await daiContract.balanceOf(sponsor1.address);
    expect(ethers.utils.formatEther(sponsor1DaiBalance)).to.equal('999300.0');
    //sponsor2 balance before refund
    let sponsor2UsdcBalance = await usdcContract.balanceOf(sponsor2.address);
    expect(ethers.utils.formatUnits(sponsor2UsdcBalance, 6)).to.equal('800.0');

    await projects.returnFundsToAllSponsors(ethers.BigNumber.from('2'));

    //sponsor1 balance after refund
    sponsor1DaiBalance = await daiContract.balanceOf(sponsor1.address);
    expect(ethers.utils.formatEther(sponsor1DaiBalance)).to.equal('1000000.0');
    //sponsor2 balance after refund
    sponsor2UsdcBalance = await usdcContract.balanceOf(sponsor2.address);
    expect(ethers.utils.formatUnits(sponsor2UsdcBalance, 6)).to.equal('1000.0');
  });
});