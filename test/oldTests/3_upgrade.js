// const { expect } = require('chai');
// const { upgrades } = require("hardhat");
//
// xdescribe('upgrade', () => {
//   // contract instances
//   let sponsors, changeMakers, changeMakers2, impactNFT_Generator, impactNFT_Generator2,
//     projects, projects2;
//   let changeDAO, organization1, organization2, sponsor1, sponsor2; //externally owned accounts
//   let arrayOfDataForMintingNFTs; //data passed into Projects: createTokens()
//   let daiContract;
//
//   function expiresInOneHour() {
//     const currentTimeinMill = Date.now();
//     const currentTimeinSeconds = Math.floor(currentTimeinMill/1000);
//     return currentTimeinSeconds + 3600;
//   };
//
//   it('Assigns signers', async () => {
//     const accounts = await hre.ethers.getSigners();
//     changeDAO = accounts[0];
//     organization1 = accounts[1];
//     sponsor1 = accounts[2];
//     sponsor2 = accounts[4];
//     organization2 = accounts[5];
//   });
//
//   it('Sets arrayOfDataForMintingNFTs', async () => {
//     arrayOfDataForMintingNFTs = [
//       {
//         sponsorAddress: sponsor1.address,
//         sponsorTokenURI: "This is the URI for sponsor1's NFT"
//       },
//       {
//         sponsorAddress: sponsor2.address,
//         sponsorTokenURI: "This is the URI for sponsor2's NFT"
//       }
//     ];
//   });
//
//   it('Deploys ChangeMakers, ImpactNFT_Generator, Projects contracts', async () => {
//       ChangeMakers = await hre.ethers.getContractFactory('ChangeMakers');
//       changeMakers = await upgrades.deployProxy(
//         ChangeMakers,
//         [],
//         { initializer: 'initialize'}
//       );
//
//       ImpactNFT_Generator = await hre.ethers.getContractFactory('ImpactNFT_Generator');
//       impactNFT_Generator = await upgrades.deployProxy(
//         ImpactNFT_Generator,
//         ['Proof of Impact', 'IMPACT'],
//         { initializer: 'initialize'}
//       );
//
//       const daiAddress = '0x6b175474e89094c44da98b954eedeac495271d0f';
//       Projects = await hre.ethers.getContractFactory('Projects');
//       projects = await upgrades.deployProxy(
//           Projects,
//           [changeMakers.address, impactNFT_Generator.address, daiAddress],
//           { initializer: 'initialize'}
//       );
//
//       daiContract = await ethers.getContractAt('IERC20', daiAddress);
//   });
//
//   it('ChangeMakers: becomeChangeMaker()', async () => {
//     //check that changeDAO is the owner of the changeMakers contract
//     let owner = await changeMakers.owner();
//     expect(owner).to.equal(changeDAO.address);
//
//     //ChangeDAO authorizes organization1.address to become a changeMaker
//     await changeMakers.authorize(organization1.address);
//     // Check the authorization status of organization1
//     const isUser1Authorized = await changeMakers.checkAuthorization(organization1.address);
//     expect(isUser1Authorized).to.equal(true);
//
//     // organization1 registers as a new changeMaker
//     await changeMakers.connect(organization1).becomeChangeMaker(
//       "XYZ Charity", //name
//     );
//   });
//
//   it('Projects: createProject(), getChangeMakerProjects()', async () => {
//     //check that changeDAO is the owner of the projects contract
//     let owner = await projects.owner();
//     expect(owner).to.equal(changeDAO.address);
//     //organization1 creates three new projects
//     expirationTime = expiresInOneHour();
//     await projects.connect(organization1).createProject(
//       "XYX first project", //name of project
//       ethers.BigNumber.from(expirationTime), //time in seconds before expiration
//       ethers.utils.parseEther('1000') //funding amount (1000*10e18);
//     );
//     expirationTime = expiresInOneHour();
//     await projects.connect(organization1).createProject(
//       "XYZ second project",
//       ethers.BigNumber.from(expirationTime),
//       ethers.utils.parseEther('1000')
//     );
//     expirationTime = expiresInOneHour();
//     await projects.connect(organization1).createProject(
//       "XYZ third project",
//       ethers.BigNumber.from(expirationTime),
//       ethers.utils.parseEther('1000')
//     );
//     //Return an array of all the project ids for the projects organization1 has created
//     const XYZprojectArray = await projects
//       .connect(changeDAO)
//       .getChangeMakerProjects(organization1.address);
//     expect(XYZprojectArray[0].toNumber()).to.equal(1);
//     expect(XYZprojectArray[1].toNumber()).to.equal(2);
//     expect(XYZprojectArray[2].toNumber()).to.equal(3);
//   });
//
//   it('sponsor1 acquires DAI', async () => {
//     //impersonate externally owned account found on etherscan (this is Binance8)
//     await hre.network.provider.request({
//       method: "hardhat_impersonateAccount",
//       params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
//     );
//     let eoa = await ethers.provider.getSigner("0xf977814e90da44bfa03b6295a0616a897441acec");
//     let daiContractComp = daiContract.connect(eoa);
//     // transfer dai to sponsor1
//     await daiContractComp.transfer(sponsor1.address, ethers.utils.parseEther('1000000'));
//     let sponsor1Balance = await daiContractComp.balanceOf(sponsor1.address);
//     expect(ethers.utils.formatEther(sponsor1Balance)).to.equal('1000000.0');
//     // transfer dai to sponsor2
//     await daiContractComp.transfer(sponsor2.address, ethers.utils.parseEther('1000000'));
//     let sponsor2Balance = await daiContractComp.balanceOf(sponsor2.address);
//     expect(ethers.utils.formatEther(sponsor2Balance)).to.equal('1000000.0');
//
//     await hre.network.provider.request({
//       method: "hardhat_stopImpersonatingAccount",
//       params: ["0xf977814e90da44bfa03b6295a0616a897441acec"]}
//     );
//   });
//
//   it('Projects: sponsor1 funds a project and gets listed as a sponsor', async () => {
//     let amount = ethers.utils.parseEther('700');
//
//     projectsSponsor1 = projects.connect(sponsor1);
//     daiContractSponsor1 = daiContract.connect(sponsor1);
//     //sponsor1 gives approval for the instance of Project.sol to transferFrom() the approved amount
//     await daiContractSponsor1.approve(projects.address, amount);
//     await projectsSponsor1.fundProject(ethers.BigNumber.from(2), amount);
//
//     let currentProjectFunding = await projectsSponsor1.currentProjectFunding(ethers.BigNumber.from(2));
//     expect(ethers.utils.formatEther(currentProjectFunding)).to.equal(ethers.utils.formatEther(amount));
//
//     let isFullyFunded = await projectsSponsor1.isProjectFullyFunded(ethers.BigNumber.from(2));
//     expect(isFullyFunded).to.equal(false);
//   });
//
//   it('Projects: sponsor2 funds project, gets listed; project is fully funded', async () => {
//     let amount = ethers.utils.parseEther('300');
//
//     projectsSponsor2 = projects.connect(sponsor2);
//     daiContractSponsor2 = daiContract.connect(sponsor2);
//     //sponsor1 gives approval for the projects instance to transferFrom() the approved amount
//     await daiContractSponsor2.approve(projects.address, amount);
//     await projectsSponsor2.fundProject(ethers.BigNumber.from(2), amount);
//
//     let currentProjectFunding = await projectsSponsor2.currentProjectFunding(ethers.BigNumber.from(2));
//     expect(ethers.utils.formatEther(currentProjectFunding)).to.equal('1000.0');
//
//     let isFullyFunded = await projectsSponsor2.isProjectFullyFunded(ethers.BigNumber.from(2));
//     expect(isFullyFunded).to.equal(true);
//   });
//
//   it('Projects: sponsor1 and sponsor2 are listed as sponsors', async () => {
//     let sponsorIds = await projects.getProjectSponsorIds(ethers.BigNumber.from(2));
//     expect(sponsorIds[0].toNumber()).to.equal(1);
//     expect(sponsorIds[1].toNumber()).to.equal(2);
//   });
//
//   it('Projects: organization1 has three project ids assigned to it', async () => {
//     let organization1ProjectIds = await projects.getChangeMakerProjects(organization1.address);
//     expect(organization1ProjectIds[0].toNumber()).to.equal(1);
//     expect(organization1ProjectIds[1].toNumber()).to.equal(2);
//     expect(organization1ProjectIds[2].toNumber()).to.equal(3);
//   });
//
//   it('Sponsors: sponsor1 and sponsor2 have project 2 in their list of sponsored projects', async () => {
//     let sponsor1ProjectIds = await projects.getProjectsOfASponsor(sponsor1.address);
//     let sponsor2ProjectIds = await projects.getProjectsOfASponsor(sponsor2.address);
//     expect(sponsor1ProjectIds[0].toNumber()).to.equal(2);
//     expect(sponsor1ProjectIds[0].toNumber()).to.equal(2);
//   });
//
//   it('Projects: ChangeDAO attempts to call createTokens but fails because not authorized', async () =>{
//     expect(projects.createTokens(arrayOfDataForMintingNFTs, ethers.BigNumber.from(2))).to.be.revertedWith("Only the authorized changeMaker can call createTokens()");
//   });
//
//   it('Projects: authorized changeMaker successfully calls createTokens()', async () => {
//     let organization1Project = projects.connect(organization1);
//     let successfulCall = await organization1Project.createTokens(
//       arrayOfDataForMintingNFTs,
//       ethers.BigNumber.from(2)
//     );
//
//     let ownerNFT1 = await impactNFT_Generator.ownerOf(ethers.BigNumber.from(1));
//     expect(ownerNFT1).to.equal(sponsor1.address);
//     let ownerNFT2 = await impactNFT_Generator.ownerOf(ethers.BigNumber.from(2));
//     expect(ownerNFT2).to.equal(sponsor2.address);
//   });
//
//   it('Projects: changeMaker calls withdrawNinetyEightPercent() and gets 98% of total funding', async () => {
//     let organization1Project = projects.connect(organization1);
//     ///changeMaker calls function to receive 98% of project funding
//     await organization1Project.withdrawNinetyEightPercent(ethers.BigNumber.from('2'));
//     let organization1Balance = await daiContract.balanceOf(organization1.address);
//     expect(ethers.utils.formatEther(organization1Balance)).to.equal('980.0');
//   });
//
//   it('Projects: ChangeDAO calls withdrawTwoPercent()', async () => {
//     await projects.withdrawTwoPercent(ethers.BigNumber.from('2'));
//     let changeDAOBalance = await daiContract.balanceOf(changeDAO.address);
//     expect(ethers.utils.formatEther(changeDAOBalance)).to.equal('20.0');
//   });
//
//   ///@notice changeMakers2, impactNFT_Generator2 and projects2 are the same contracts as changeMakers, impactNFT_Generator and projects.  They are the proxies that point to logic contracts.  Even though new logic contracts are deployed, the proxies do not change.  The naming of these proxies with "2" is only done to emphasize that the logic contracts have been upgraded.
//   it('ChangeMakers2: Upgrade to ChangeMakers2', async () => {
//     ChangeMakers2 = await hre.ethers.getContractFactory('ChangeMakers2');
//     changeMakers2  = await upgrades.upgradeProxy(changeMakers.address, ChangeMakers2);
//     expect(changeMakers2.address).to.equal(changeMakers.address);
//
//     await changeMakers2.setStorageValue(ethers.BigNumber.from('15'));
//     let storageValue = await changeMakers2.storageValue();
//     expect(storageValue.toNumber()).to.equal(15);
//   });
//
//   it('ImpactNFT_Generator2: Upgrade to ImpactNFT_Generator2', async () => {
//     ImpactNFT_Generator2 = await hre.ethers.getContractFactory('ImpactNFT_Generator2');
//     impactNFT_Generator2 = await upgrades.upgradeProxy(
//       impactNFT_Generator.address,
//       ImpactNFT_Generator2
//     );
//     expect(impactNFT_Generator2.address).to.equal(impactNFT_Generator.address);
//
//     await impactNFT_Generator2.setStorageValue(ethers.BigNumber.from('15'));
//     let storageValue = await impactNFT_Generator2.storageValue();
//     expect(storageValue.toNumber()).to.equal(15);
//   });
//
//   it('Projects2: Upgrade to Projects2', async () => {
//     Projects2 = await hre.ethers.getContractFactory('Projects2');
//     projects2 = await upgrades.upgradeProxy(projects.address, Projects2);
//     expect(projects2.address).to.equal(projects.address);
//
//     await projects2.setStorageValue(ethers.BigNumber.from('15'));
//     let storageValue = await projects2.storageValue();
//     expect(storageValue.toNumber()).to.equal(15);
//
//     const daiAddress = '0x6b175474e89094c44da98b954eedeac495271d0f';
//     await projects2.reInitialize(
//       changeMakers2.address,
//       impactNFT_Generator2.address,
//       daiAddress
//     );
//   });
//
//   it('ChangeMakers2: becomeChangeMaker()', async () => {
//     //check that changeDAO is the owner of the changeMakers contract
//     let owner = await changeMakers2.owner();
//     expect(owner).to.equal(changeDAO.address);
//
//     //ChangeDAO authorizes organization1.address to become a changeMaker
//     await changeMakers2.authorize(organization2.address);
//     // Check the authorization status of organization1
//     const isUser2Authorized = await changeMakers2.checkAuthorization(organization2.address);
//     expect(isUser2Authorized).to.equal(true);
//
//     // organization1 registers as a new changeMaker
//     await changeMakers2.connect(organization2).becomeChangeMaker(
//       "UVW Charity", //name
//     );
//   });
//
//   it('Projects2: createProject(), getChangeMakerProjects()', async () => {
//     //check that changeDAO is the owner of the projects contract
//     let owner = await projects2.owner();
//     expect(owner).to.equal(changeDAO.address);
//     //organization1 creates three new projects
//     expirationTime = expiresInOneHour();
//     await projects.connect(organization2).createProject(
//       "UVW first project", //name of project
//       ethers.BigNumber.from(expirationTime), //time in seconds before expiration
//       ethers.utils.parseEther('1000') //funding amount (1000*10e18);
//     );
//     expirationTime = expiresInOneHour();
//     await projects.connect(organization2).createProject(
//       "UVW second project",
//       ethers.BigNumber.from(expirationTime),
//       ethers.utils.parseEther('1000')
//     );
//     expirationTime = expiresInOneHour();
//     await projects.connect(organization2).createProject(
//       "UVW third project",
//       ethers.BigNumber.from(expirationTime),
//       ethers.utils.parseEther('1000')
//     );
//     //Return an array of all the project ids for the projects organization1 has created
//     const UVWprojectArray = await projects2
//       .connect(changeDAO)
//       .getChangeMakerProjects(organization2.address);
//     expect(UVWprojectArray[0].toNumber()).to.equal(4);
//     expect(UVWprojectArray[1].toNumber()).to.equal(5);
//     expect(UVWprojectArray[2].toNumber()).to.equal(6);
//   });
//
//   it('Projects2: sponsor1 funds a project and gets listed as a sponsor', async () => {
//     let amount = ethers.utils.parseEther('400');
//
//     projects2Sponsor1 = projects2.connect(sponsor1);
//     daiContractSponsor1 = daiContract.connect(sponsor1);
//     //sponsor1 gives approval for the instance of Project.sol to transferFrom() the approved amount
//     await daiContractSponsor1.approve(projects2.address, amount);
//     await projects2Sponsor1.fundProject(ethers.BigNumber.from(5), amount);
//
//     let currentProjectFunding = await projects2Sponsor1
//       .currentProjectFunding(ethers.BigNumber.from(5));
//     expect(ethers.utils.formatEther(currentProjectFunding)).to.equal(ethers.utils.formatEther(amount));
//
//     let isFullyFunded = await projectsSponsor1.isProjectFullyFunded(ethers.BigNumber.from(5));
//     expect(isFullyFunded).to.equal(false);
//   });
//
//   it('Projects2: sponsor2 funds project, gets listed; project is fully funded', async () => {
//     let amount = ethers.utils.parseEther('600');
//
//     projects2Sponsor2 = projects.connect(sponsor2);
//     daiContractSponsor2 = daiContract.connect(sponsor2);
//     //sponsor1 gives approval for the projects instance to transferFrom() the approved amount
//     await daiContractSponsor2.approve(projects2.address, amount);
//     await projects2Sponsor2.fundProject(ethers.BigNumber.from(5), amount);
//
//     let currentProjectFunding = await projects2Sponsor2
//       .currentProjectFunding(ethers.BigNumber.from(5));
//     expect(ethers.utils.formatEther(currentProjectFunding)).to.equal('1000.0');
//
//     let isFullyFunded = await projectsSponsor2.isProjectFullyFunded(ethers.BigNumber.from(5));
//     expect(isFullyFunded).to.equal(true);
//   });
//
//   it('Projects2: sponsor1 and sponsor2 are listed as sponsors', async () => {
//     let sponsorIds = await projects2.getProjectSponsorIds(ethers.BigNumber.from(5));
//     expect(sponsorIds[0].toNumber()).to.equal(3);
//     expect(sponsorIds[1].toNumber()).to.equal(4);
//   });
//
//   it('Projects2: organization2 has three project ids assigned to it', async () => {
//     let organization2ProjectIds = await projects.getChangeMakerProjects(organization2.address);
//     expect(organization2ProjectIds[0].toNumber()).to.equal(4);
//     expect(organization2ProjectIds[1].toNumber()).to.equal(5);
//     expect(organization2ProjectIds[2].toNumber()).to.equal(6);
//   });
//
//   it('Sponsors2: sponsor1 and sponsor2 have project 5 in their list of sponsored projects',
//     async () => {
//       let sponsor1ProjectIds = await projects.getProjectsOfASponsor(sponsor1.address);
//       let sponsor2ProjectIds = await projects.getProjectsOfASponsor(sponsor2.address);
//       expect(sponsor1ProjectIds[1].toNumber()).to.equal(5);
//       expect(sponsor1ProjectIds[1].toNumber()).to.equal(5);
//   });
//
//   it('Projects2: ChangeDAO attempts to call createTokens but fails because not authorized',
//     async () =>{
//       expect(projects2.createTokens(arrayOfDataForMintingNFTs, ethers.BigNumber.from(5))).to.be.revertedWith("Only the authorized changeMaker can call createTokens()");
//   });
//
//   it('Projects2: authorized changeMaker successfully calls createTokens()', async () => {
//     let organization2Project = projects2.connect(organization2);
//     let successfulCall = await organization2Project.createTokens(
//       arrayOfDataForMintingNFTs,
//       ethers.BigNumber.from(5)
//     );
//
//     let ownerNFT3 = await impactNFT_Generator2.ownerOf(ethers.BigNumber.from(3));
//     expect(ownerNFT3).to.equal(sponsor1.address);
//     let ownerNFT4 = await impactNFT_Generator2.ownerOf(ethers.BigNumber.from(4));
//     expect(ownerNFT4).to.equal(sponsor2.address);
//   });
//
//   it('Projects2: changeMaker calls withdrawNinetyEightPercent() and gets 98% of total funding',
//     async () => {
//       let organization2Project = projects2.connect(organization2);
//       ///changeMaker calls function to receive 98% of project funding
//       await organization2Project.withdrawNinetyEightPercent(ethers.BigNumber.from('5'));
//       let organization2Balance = await daiContract.balanceOf(organization2.address);
//       expect(ethers.utils.formatEther(organization2Balance)).to.equal('980.0');
//   });
//
//   it('Projects2: ChangeDAO calls withdrawTwoPercent()', async () => {
//     await projects.withdrawTwoPercent(ethers.BigNumber.from('5'));
//     let changeDAOBalance = await daiContract.balanceOf(changeDAO.address);
//     expect(ethers.utils.formatEther(changeDAOBalance)).to.equal('40.0');
//   });
// });
