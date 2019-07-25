pragma solidity ^ 0.4.19;

import "./ownable.sol";

contract Perpare is Ownable{




mapping (address => uint) public  deposit;
mapping (address => uint) balance;




//用户获取代币
function getToken () public returns(bool) {
  balance[msg.sender] += 2000;
  return true;
  
}

//显示余额
function balanceAmount() public view returns(uint) {
    return balance[msg.sender];
}










}