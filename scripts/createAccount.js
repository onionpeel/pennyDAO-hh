const hre = require('hardhat');


async function main() {
  const mnemonic = ethers.Wallet.createRandom();
  console.log(mnemonic.mnemonic)
  const walletMnemonic = ethers.Wallet.fromMnemonic(mnemonic.mnemonic.phrase);
  console.log(walletMnemonic)

  const walletPrivateKey = new ethers.Wallet(walletMnemonic.privateKey);
  console.log('private key: ', walletPrivateKey._signingKey())
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error);
    process.exit(1);
  });
