const hre = require('hardhat');
const fs = require("fs");
const path = require('path');

//This will create a directory for the addresses in the root.  Change the destination to React's src if using that as a frontend
const setAddressInCompiledContracts = (instance, contractName) => {
  //Create a directory on the root level that will hold a file which stores addresses of deployed contracts
  const contractsDir = path.join(__dirname, "..", `contractAddresses`);
  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  };
  //create a contractAddress.json file in contractsDir and add address information for each contract
  if(!fs.existsSync(path.join(contractsDir, "contractAddresses.json"))) {
    let instanceAddressPath = path.join(contractsDir, "contractAddresses.json");
    fs.writeFileSync(
      instanceAddressPath,
      JSON.stringify({ [contractName]: instance.address }, undefined, 2)
    );
  } else {
    let instanceAddressPath = path.join(contractsDir, "contractAddresses.json");
    let data = fs.readFileSync(instanceAddressPath);
    let json = JSON.parse(data);
    json = {
      ...json,
      [contractName]: instance.address
    };
    json = JSON.stringify(json, undefined, 2);
    fs.writeFileSync(instanceAddressPath, json);
  };
};

async function deploy(name, ...params) {
  const Contract = await hre.ethers.getContractFactory(name);
  const contract = await Contract.deploy(...params).then(c => c.deployed());

  setAddressInCompiledContracts(contract, name);
  console.log(`Deploying ${name} at ${contract.address}`);

  return contract;
};

async function main() {
  // const accounts = await hre.ethers.getSigners();
  // const user1 = accounts[0];
  // const user2 = accounts[1];

  const changeMakers = await deploy('ChangeMakers');
  const projects = await deploy('Projects', changeMakers.address);
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error);
    process.exit(1);
  });
