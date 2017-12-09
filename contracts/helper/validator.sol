pragma solidity ^0.4.11;

library validator {

	//[0-9]{4}
	function validatePin(string str) constant internal returns (bool){
		bytes memory b = bytes(str);
		if(b.length != 4) return false;
		for(uint i; i < b.length; i++) {
			if(b[i] < 48 || b[i] > 57) return false;
		}

		return true;
	}

	function validatePhone(string str) constant internal returns (bool){
		bytes memory b = bytes(str);
		if(b.length != 10) return false;
		for(uint i; i < b.length; i++) {
			if(b[i] < 48 || b[i] > 57) return false;
		}

		//begins with 0
		if(b[0] == 48) return false;

		return true;
	}

	//[1-2][0-9]{3}\-[0-1][0-9]\-[0-3][0-9]
	//2000-01-30
	function validateDob(string str) constant internal returns (bool){
		bytes memory b = bytes(str);
		if(b.length != 10) return false;
		for(uint i; i < b.length; i++) {
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
	function validateSsn(string str) constant internal returns (bool){
		bytes memory b = bytes(str);
		if(b.length != 9) return false;
		for(uint i; i < b.length; i++) {
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

    function validateAuthmanId(string str) constant internal returns (bool) {
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

  }