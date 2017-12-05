pragma solidity ^0.4.11;

library myString {

  //https://ethereum.stackexchange.com/questions/6591/conversion-of-uint-to-string
  function uintToBytes(uint v) constant internal returns (string ret) {
    
    return bytes32ToString(bytes32(v));
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

    /* bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed); */
  }

  //https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
  function strConcat(string _a, string _b, string _c, string _d, string _e) constant internal returns (string){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
  }

  function strConcat(string _a, string _b, string _c, string _d) constant internal returns (string) {
      return strConcat(_a, _b, _c, _d, "");
  }

  function strConcat(string _a, string _b, string _c) constant internal returns (string) {
      return strConcat(_a, _b, _c, "", "");
  }

  function strConcat(string _a, string _b) constant internal returns (string) {
      return strConcat(_a, _b, "", "", "");
  }

  function substring(string str, uint startIndex, uint endIndex) constant internal returns (string) {
    bytes memory strBytes = bytes(str);
    bytes memory result = new bytes(endIndex-startIndex);
    for(uint i = startIndex; i < endIndex; i++) {
        result[i-startIndex] = strBytes[i];
    }
    return string(result);
  }

  function addressToString(address x) constant internal returns (string) {
    bytes memory b = new bytes(20);
    for (uint i = 0; i < 20; i++)
        b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
    return string(b);
  }
  
}