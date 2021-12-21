// const { BN, ether, balance } = require('openzeppelin-test-helpers');
const usdc = artifacts.require("FakeUSDC");

// const forceSendETH = artifacts.require("ForceSendETH");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
// ABI
const erc20ABI = require('./abi/usdc');
// console.log(erc20ABI);
// saiAddress must be unlocked using --unlock 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359
const usdcAddress = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
const usdcContract = new web3.eth.Contract(erc20ABI, usdcAddress);
const usdcUserAddress = "0x72a53cdbbcc1b9efa39c834a540550e23463aacb";

contract("FakeUSDC", function ( accounts ) {
  it("Fund USDC Test account", async function () {
    // console.log(usdcContract);
    console.log(accounts[0]);
    await usdc.deployed();
    await usdcContract.methods.transfer(accounts[0], "10000000000000")
        .send({ from:  usdcUserAddress});
    return assert.isTrue(true);
  });
});
