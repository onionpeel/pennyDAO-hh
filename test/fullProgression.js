const { expect } = require('chai');

describe('Projects.sol', () => {
  let changeMakers, impactNFT_Generator, projects, deployer, organization1, sponsor1;

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

  it('Projects: sponsor1 acquires DAI', async () => {
    let daiContract = await ethers.getContractAt('IERC20', '0x6b175474e89094c44da98b954eedeac495271d0f');
    // const compoundBalance = await daiContract.balanceOf('0x5d3a536e4d6dbd6114cc1ead35777bab948e3643');
    // console.log('compoundBalance: ', ethers.utils.formatEther(compoundBalance));
    //impersonate the Compound contract
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x5d3a536e4d6dbd6114cc1ead35777bab948e3643"]}
    );
    let compoundSigner = await ethers.provider.getSigner("0x5d3a536e4d6dbd6114cc1ead35777bab948e3643");
    compoundSigner.address = compoundSigner._address;
    let daiContractComp = daiContract.connect(compoundSigner);
    // console.log(daiContract)
    // let sponsor1Balance = await daiContract.balanceOf(sponsor1.address);
    // console.log('sponsor1Balance: ', ethers.utils.formatEther(sponsor1Balance));

    let compoundSignerBalance = await daiContractComp.balanceOf(compoundSigner.address);
    console.log('compoundSignerBalance: ', ethers.utils.formatEther(compoundSignerBalance));
    // console.log('daiContractComp signer: ', daiContractComp.signer);

    let totalSupply = await daiContractComp.totalSupply();
    console.log('totalSupply: ', ethers.utils.formatEther(totalSupply));

    await daiContractComp.transfer(sponsor1.address, ethers.utils.parseEther('1000'));
  });
});
