pragma solidity ^0.4.17;

import "./myString.sol";

library util {

	function createClaimHash(address _address, bytes32 pin) constant internal returns (bytes32) {
		return keccak256(myString.strConcat(myString.addressToString(_address), myString.bytes32ToString(pin)));
	}

	function createSsnHash(bytes32 ssn, bytes32 dob) constant internal returns (bytes32) {

		string memory ssnStr = myString.bytes32ToString(ssn);

		//split ssn into 3 parts of 3 chars
	  string [] memory ssnArr = new string[](3);
		ssnArr[0] = myString.substring(ssnStr, 0, 3);
		ssnArr[1] = myString.substring(ssnStr, 3, 6);
		ssnArr[2] = myString.substring(ssnStr, 6, 9);

		string memory dobStr = myString.bytes32ToString(dob);

		//split dob
		string [] memory dobArr = new string[](3);
		dobArr[0] = myString.substring(dobStr, 0, 4);
		dobArr[1] = myString.substring(dobStr, 5, 7);
		dobArr[2] = myString.substring(dobStr, 8, 10);

		string memory pipe = "|";
		string memory tilde = "~";

		//concat them like YYYY|S1~MM|S2~DD|N3
		string memory hash = myString.strConcat(dobArr[0], pipe, ssnArr[0], tilde, dobArr[1]);
		hash = myString.strConcat(hash, pipe, ssnArr[1], dobArr[2]);
		hash = myString.strConcat(hash, pipe, ssnArr[2]);

		//SSN+DOB keccak256
		return keccak256(hash);

	}

}