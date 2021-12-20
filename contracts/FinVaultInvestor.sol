// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/ILendingPool.sol";
import "./comp/cERC20.sol";

// A contract that accepts USDC from users and extends the Ownable contract 
contract FinVaultInvestor is Ownable {
    using SafeMath for uint;

    // User balances
    mapping(address=>uint) public balances;

    // Total investment sum
    uint public totalInvestment;

    uint public totalInvestmentSumAave;

    uint public totalInvestmentSumComp;

    //Acceptable token contract
    // 0x07865c6E87B9F70255377e024ace6630C1Eaa37F - Goerli
    address usdcToken;

    // Events
    // Transfer successful Event
    event Transfer(address from, address to, uint amount);

    // Log transaction message and status (1 => Success, other code for failure).
    event LogTransaction(string, uint256);

    //AAVE Liquidy provider
    ILendingPoolAddressesProvider liquidityPoolProviderAave;

    // FakeUSDC 0x2dB6a31f973Ec26F5e17895f0741BB5965d5Ae15 
    // aUSDC 0xBcca60bB61934080951369a648Fb03DF4F96263C;
    // Get faucet from https://testnet.aave.com/faucet
    IERC20 aToken; 

    //0xcec4a43ebb02f9b80916f1c718338169d6d5c1f0 - Goerli
    //0x2973e69b20563bcc66dc63bde153072c33ef37fe - Ropsten
    //0x851dEf71f0e6A903375C1e536Bd9ff1684BAD802 - aave usdc ropsten
    address cUsdc; 


    // Create the contract with the _acceptableTokenAddress - USDC: contract 0x822D11AEF505e781c5669109922AC570189A5fb3
    // @param liquidityPoolAave as the AAVE Ilending provider, which allows the contract to have access to the current lending pool contract. 
    // Lending pool provider 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5
    // Lending pool contract 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9
    // @param liquidityPoolComp as the COMP contract: 
    constructor(address _usdcToken, ILendingPoolAddressesProvider _liquidityPoolProviderAave, address _cUsdc) {
        usdcToken = _usdcToken;
        liquidityPoolProviderAave = _liquidityPoolProviderAave;
        cUsdc = _cUsdc;
    }

    // When a user deposits USDC, transfer the usdc to this contract
    // If transfer is successful, update the userbalance
    // Update totalInvestmentSum
    // Check investment pool with the highest interest
    // Invest in the pool with the highest interest
    // map user investment information and balances
    function stakeFunds(uint _amount) public payable {
        require(_amount > 0, "amount cannot be 0");
        IERC20 usdc = IERC20(usdcToken);
        totalInvestment = totalInvestment.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
        usdc.transferFrom(msg.sender, address(this), _amount);
        
        //Emit transfer event
        emit Transfer(msg.sender, address(this), _amount);
    }


   // Compare the interest rates for AAVE and COMP 
    function compareInterestRate(uint amount) public returns(address){
        // Get AAVE interest rate
        uint aaveInterestRate = 0; // use the AAVE interestRateContract
        // Get COMP interest rate
        uint compInterestRate = 0; // get the interest Rate

        if(aaveInterestRate > compInterestRate){
            return liquidityPoolProviderAave.getLendingPool();
        }
        return cUsdc;
    }
    

    // Redeem investment interest and principal from
    // Transfer to the user
    function redeemFundsFromContract(uint _amount) public payable {
        //validate balance;
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        totalInvestment = totalInvestment.sub(_amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        IERC20(usdcToken).transfer(msg.sender, _amount);
        
        //Emit transfer event
        emit Transfer(msg.sender, address(this), _amount);
    }

    // Stake AAVE 
    function stakeAave(uint amount) public {
        ILendingPool aavePool = ILendingPool(liquidityPoolProviderAave.getLendingPool());
        //deposit(address asset, uint256 amount,address onBehalfOf,uint16 referralCode
        aavePool.deposit(usdcToken, amount, address(this), 0);
    }

    //supply ERC20 to compound
    function supplyUSDCToCompound(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) public returns (uint) {
        // Create a reference to the underlying asset contract, like DAI.
        IERC20 underlying = IERC20(_erc20Contract);

        // Create a reference to the corresponding cToken contract, like cDAI
        CErc20 cToken = CErc20(_cErc20Contract);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit LogTransaction("Exchange Rate (scaled up): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit LogTransaction("Supply Rate: (scaled up)", supplyRateMantissa);

        // Approve transfer on the ERC20 contract
        underlying.approve(_cErc20Contract, _numTokensToSupply);

        // Mint cTokens
        uint mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }


    // Stake USDC to COMP protocol
    // send funds to this contracts
    function stakeComp(uint amount) public {
        stakeFunds(amount);
        uint responseCode = supplyUSDCToCompound(usdcToken, cUsdc, amount);
        emit LogTransaction("Amount supplied to cUSDC successfull", responseCode);
    }


    // https://compound.finance/docs#protocol-math
    // https://compound.finance/docs/ctokens#error-codes
    // @return bool
    function redeemCUsdcTokens(
        uint256 amount,
        bool redeemType,
        address _cErc20Contract
    ) public returns (bool) {
        // Create a reference to the corresponding cToken contract, like cDAI
        CErc20 cToken = CErc20(_cErc20Contract);

        uint256 redeemResult;

        if (redeemType == true) {
            // Retrieve your asset based on a cToken amount
            redeemResult = cToken.redeem(amount);
        } else {
            // Retrieve your asset based on an amount of the asset
            redeemResult = cToken.redeemUnderlying(amount);
        }

        emit LogTransaction("If this is not 0, there was an error", redeemResult);
        return true;
    }

    function redeemComp(uint amount) public {
        bool result = redeemCUsdcTokens(amount, true, cUsdc);
        // Perhaps a check for successful response?
        redeemFundsFromContract(amount);
    }

    function redeemAave(uint amount) public {}

    receive() external payable{}

}
