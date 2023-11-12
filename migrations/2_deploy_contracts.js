const MultiSigWallet = artifacts.require("MultiSigWallet");

module.exports = function (deployer, network, accounts) {
  deployer.then(async () => {

    if (network === "develop") {
      await deployer.deploy(MultiSigWallet);
    }
    else if (network === "goerli" || network === "ethereum") {
      await deployer.deploy(MultiSigWallet);
    }
    else {
      await deployer.deploy(MultiSigWallet);
    }
  });
};
