const { expect } = require('chai');

describe('Projects.sol', () => {
  let changeMakers, projects, deployer, organization1, sponsor1;

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

    Projects = await hre.ethers.getContractFactory('Projects');
    projects = await Projects.deploy(changeMakers.address);
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

  it('Escrow: fundProject()', async () => {
    
  });
});
