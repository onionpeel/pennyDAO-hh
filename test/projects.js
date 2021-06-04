const { expect } = require('chai');

describe('Projects', () => {
  let changeMakers, projects, deployer, organization1;

  it('deploys contracts and assigns signers', async () => {
    const accounts = await hre.ethers.getSigners();
    deployer = accounts[0];
    organization1 = accounts[1];

    ChangeMakers = await hre.ethers.getContractFactory('ChangeMakers');
    changeMakers = await ChangeMakers.deploy();

    Projects = await hre.ethers.getContractFactory('Projects');
    projects = await Projects.deploy(changeMakers.address);
  });

  it('Projects: createProject() ', async () => {
    function getCurrentTime() {
      const currentTimeinMill = Date.now();
      const currentTimeinSeconds = Math.floor(currentTimeinMill/1000);
      return currentTimeinSeconds;
    };
    let currentTime = getCurrentTime();
    //changeMakers authorizes organization1.address to become a changeMaker
    await changeMakers.authorize(organization1.address);
    const isUser1Authorized = await changeMakers.checkAuthorization(organization1.address);
    expect(isUser1Authorized).to.equal(true);
    //organization1 registers as a new changeMaker
    await changeMakers.connect(organization1).becomeChangeMaker(
      "XYZ Charity",
      ethers.BigNumber.from(currentTime)
    );
    //organization1 creates a new project
    currentTime = getCurrentTime();
    await projects.connect(organization1).createProject(
      "A Great New Project",
      ethers.BigNumber.from(currentTime)
    );

    const project = await projects.connect(deployer).getChangeMakerProjects(organization1.address);
    expect(project[0].changeMaker).to.equal(organization1.address);
    expect(project[0].name).to.equal("A Great New Project");
    expect(project[0].creationTime.toString()).to.equal(currentTime.toString());
  });

});
