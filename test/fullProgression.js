const { expect } = require('chai');

describe('Projects.sol', () => {
  let changeMakers, impactNFT_Generator, projects, deployer, organization1, sponsor1, sponsor2;

  function expiresInOneHour() {
    const currentTimeinMill = Date.now();
    const currentTimeinSeconds = Math.floor(currentTimeinMill/1000);
    return currentTimeinSeconds + 3600;
  };

  it('deploys ChangeMakers and Projects contracts; assigns signers', async () => {
    const accounts = await hre.ethers.getSigners();
    deployer = accounts[0];
    organization1 = accounts[1];
    sponsor1 = accounts[2];
    sponsor2 = accounts[4];

    ChangeMakers = await hre.ethers.getContractFactory('ChangeMakers');
    changeMakers = await ChangeMakers.deploy();

    ImpactNFT_Generator = await hre.ethers.getContractFactory('ImpactNFT_Generator');
    impactNFT_Generator = await ImpactNFT_Generator.deploy('Proof of Impact', 'IMPACT');

    Projects = await hre.ethers.getContractFactory('Projects');
    projects = await Projects.deploy(changeMakers.address, impactNFT_Generator.address);
  });

  it('ChangeMakers: becomeChangeMaker()', async () => {
    //ChangeDao authorizes organization1.address to become a changeMaker
    await changeMakers.authorize(organization1.address);
    //Check the authorization status of organization1
    const isUser1Authorized = await changeMakers.checkAuthorization(organization1.address);
    expect(isUser1Authorized).to.equal(true);

    //organization1 registers as a new changeMaker
    await changeMakers.connect(organization1).becomeChangeMaker(
      "XYZ Charity", //name
    );
  });

  it('Projects: createProject(), getChangeMakerProjects()', async () => {
    //organization1 creates three new projects
    expirationTime = expiresInOneHour();
    await projects.connect(organization1).createProject(
      "XYX first project",
      ethers.BigNumber.from(expirationTime),
      ethers.BigNumber.from(1000) //fundingThreshold
    );
    expirationTime = expiresInOneHour();
    await projects.connect(organization1).createProject(
      "XYZ second project",
      ethers.BigNumber.from(expirationTime),
      ethers.BigNumber.from(1000) //fundingThreshold
    );
    expirationTime = expiresInOneHour();
    await projects.connect(organization1).createProject(
      "XYZ third project",
      ethers.BigNumber.from(expirationTime),
      ethers.BigNumber.from(1000) //fundingThreshold
    );
    //Return an array of all the project ids for the projects organization1 has created
    const XYZprojectArray = await projects.connect(deployer).getChangeMakerProjects(organization1.address);
    expect(XYZprojectArray[0].toNumber()).to.equal(1);
    expect(XYZprojectArray[1].toNumber()).to.equal(2);
    expect(XYZprojectArray[2].toNumber()).to.equal(3);
  });

  it('sponsor1 acquires DAI', async () => {
    let daiContract = await ethers.getContractAt('IERC20', '0x6b175474e89094c44da98b954eedeac495271d0f');
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

  it('Projects: sponsor1 funds a project and gets listed as a sponsor', async () => {

  });
});
