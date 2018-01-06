pragma solidity ^0.4.17;

library validator {

	//[0-9]{4}
	function validatePin(bytes32 b) constant internal returns (bool){

		if (!validateLength(b, 4, 4)) {
			return false;
		}

		for(uint i; i < 4; i++) {
			if(b[i] == 0) return false;
			if(b[i] < 48 || b[i] > 57) return false;
		}

		return true;
	}

	function validatePhone(bytes32 b) constant internal returns (bool){
		//begins with 0
		if(b[0] == 48) return false;

		if (!validateLength(b, 10, 10)) {
			return false;
		}

		for(uint i; i < 10; i++) {
			if(b[i] == 0) return false;
			if(b[i] < 48 || b[i] > 57) return false;
		}

		return true;
	}

	//[1-2][0-9]{3}\-[0-1][0-9]\-[0-3][0-9]
	//2000-01-30
	function validateDob(bytes32 b) constant internal returns (bool){

		if (!validateLength(b, 10, 10)) {
			return false;
		}

		for(uint i; i < 10; i++) {
			if(b[i] == 0) return false;
			if (i == 0) {
				if (b[i] != 49 && b[i] != 50) return false;
			}
			if (i == 1 || i == 2 || i == 3 || i == 6 || i == 9) {
				if(b[i] < 48 || b[i] > 57) return false;
			}
			if (i == 4 || i == 7) {
				if(b[i] != 45) return false;
			}
			if (i == 5) {
				if (b[i] != 48 && b[i] != 49) return false;
			}
			if (i == 8) {
				if(b[i] < 48 || b[i] > 51) return false;
			}
		}

		return true;
	}

	//https://regex101.com/r/rP8wL0/1 ^(?!(000|666|9))\d{3}(?!00)\d{2}(?!0000)\d{4}$
	//123456789
	function validateSsn(bytes32 b) constant internal returns (bool){

		if (!validateLength(b, 9, 9)) {
			return false;
		}

		for(uint i; i < 9; i++) {
			if(b[i] == 0) return false;
			if(b[i] < 48 || b[i] > 57) return false;
		}
		//begins with 9
		if(b[0] == 57) return false;

		//begins with 000
		if(b[0] == 48 && b[1] == 48 && b[2] == 48) return false;

		//begins with 666
		if(b[0] == 54 && b[1] == 54 && b[2] == 54) return false;

		//middle is 00
		if(b[3] == 48 && b[4] == 48) return false;

		//end is 0000
		if(b[5] == 48 && b[6] == 48 && b[7] == 48 && b[8] == 48) return false;

		return true;
	}

	/*
    6 - 20 characers, 
    all lower case
    begin with lower case
    one period is allowed in the middle but optional
    at least one alphabet
    numbers are allowed but optional
    */

    function validateAuthmanId(bytes32 authmanId) constant internal returns (bool) {
    	string memory str = bytes32ToString(authmanId);
    	bytes memory b = bytes(str);
    	if(b.length < 6 || b.length > 20) return false;

    	uint countPeriod = 0;
    	uint countLowerLetter = 0;

    	for(uint i; i < b.length; i++) {

    		if((b[i] < 48 || b[i] > 57)
    			&& (b[i] < 97 || b[i] > 122)
    			&& b[i] != 46) return false;
    		
    		//begin with lower case
    		if (i == 0) {
    			if (b[i] < 97 || b[i] > 122) return false;
    		}
    		
    		//cannot end with period
    		if (i == (b.length - 1)) {
    			if (b[i] == 46) return false;
    		}
    		
    		if (b[i] == 46) {
    			countPeriod ++;
    			if (countPeriod > 1) return false;    
    		}
    		
    		if (b[i] >= 97 && b[i] <= 122) {
    			countLowerLetter ++;
    		}
    	}

    	if (countLowerLetter == 0) return false;

    	return true;
    }

    function validateLength(bytes32 b, uint minLength, uint maxLength) 
    constant public returns (bool) {

    	for (uint i = 0; i < 32; i++) {
    		if (i < minLength) {
    			if(b[i] == 0) return false;
    		}
    		if (i > maxLength - 1) {
    			if(b[i] != 0) return false;  
    		}
    	}

    	return true;
    }

    function bytes32ToString (bytes32 x) constant internal returns (string) {
    	bytes memory bytesString = new bytes(32);
    	for (uint j=0; j<32; j++) {
    		byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
    		if (char != 0) {
    			bytesString[j] = char;
    		}
    	}
    	return string(bytesString);
    }

  }