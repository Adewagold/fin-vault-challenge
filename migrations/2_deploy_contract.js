const TestPoolAddress = artifacts.require("./TestPoolAddress.sol");

module.exports = function (deployer) {
  deployer.deploy(TestPoolAddress, "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5");
};
