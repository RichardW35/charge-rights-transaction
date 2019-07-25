pragma solidity ^ 0.4.19;


import "./p2p.sol";


contract Txsettle is P2P {





//退还保证金
function withdraw (bool _confirm) public returns(bool) {
	if (_confirm) {
		balance[msg.sender] += deposit[msg.sender];
		deposit[msg.sender] = 0;
		return true;
	}

	else {
		deposit[msg.sender] = 0;
		return false;
	}
}





}


