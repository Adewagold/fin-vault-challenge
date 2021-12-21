// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import {ILendingPoolAddressesProvider} from './aave/ILendingPoolAddressesProvider.sol';
contract TestPoolAddress {

  address public aaveLendingPool ;

  constructor(address _aaveLendingPool) public {
    aaveLendingPool = _aaveLendingPool;
  }

  function getCurrentLendingPool() public view returns(address){
    ILendingPoolAddressesProvider aaveProvider = ILendingPoolAddressesProvider(aaveLendingPool);
    return aaveProvider.getLendingPool();
  }
}
