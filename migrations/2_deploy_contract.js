const TestPoolAddress = artifacts.require("./TestPoolAddress.sol");
const FakeUSDC = artifacts.require("./FakeUSDC.sol");
const ForceSend = artifacts.require("./ForceSend.sol");

module.exports = function (deployer) {
  deployer.deploy(TestPoolAddress, "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5");
  deployer.deploy(FakeUSDC);
  deployer.deploy(ForceSend);
};
