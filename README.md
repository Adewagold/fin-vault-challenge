# fin-vault-challenge

Create a smart contract that: 
1. Accepts from multiple users USDC
2. Lends out the USDC on AAVE or COMPOUND (depending on whichever has the highest rate of interest) 
3. When a user withdraws their AMUSDC from AAVE or cUSDC from COMPOUND, it then gives them their principal USDC + any individual interest they have collected

___
Test contract addresses

    //0xcec4a43ebb02f9b80916f1c718338169d6d5c1f0 - Goerli, 
    //0x2973e69b20563bcc66dc63bde153072c33ef37fe - Ropsten, 
    //0x851dEf71f0e6A903375C1e536Bd9ff1684BAD802 - aave usdc ropsten
_usdcToken - USDC asset address ->     

_liquidityPoolProviderAave - A permanent contract that can be used to retrieve the current deployed liquidity pool contract.

    //0xcec4a43ebb02f9b80916f1c718338169d6d5c1f0 - Goerli
    //0x2973e69b20563bcc66dc63bde153072c33ef37fe - Ropsten
    //0x851dEf71f0e6A903375C1e536Bd9ff1684BAD802 - aave usdc ropsten
_cUsdc - compound USDC token pegged to USDC - 


    // FakeUSDC 0x2dB6a31f973Ec26F5e17895f0741BB5965d5Ae15 
    // aUSDC 0xBcca60bB61934080951369a648Fb03DF4F96263C;
    // Get faucet from https://testnet.aave.com/faucet
    IERC20 aToken;
___
## Deploy token using the asset address, AAVE's lending pool address, and Compound usdc address
     // Create the contract with the _acceptableTokenAddress - USDC: contract 0x822D11AEF505e781c5669109922AC570189A5fb3
    // @param liquidityPoolAave as the AAVE Ilending provider, which allows the contract to have access to the current lending pool contract. 
    // Lending pool provider 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5
    // Lending pool contract 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9
    // @param liquidityPoolComp as the COMP contract: 
`constructor(address _usdcToken, ILendingPoolAddressesProvider _liquidityPoolProviderAave, address _cUsdc) {
        usdcToken = _usdcToken;
        liquidityPoolProviderAave = _liquidityPoolProviderAave;
        cUsdc = _cUsdc;
    }`
