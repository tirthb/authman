  pragma solidity ^0.4.15;

  contract MyNewTest {
    
    event Info(string message);
    event LogHash(bytes32 message);

    function testPrintHash(string s) public {
      var out = keccak256(s);
      LogHash(out);
    }

    function testPrintHashAsString(string s) public {
      var out = bytes32ToString(keccak256(s));
      Info(out);
    }

    function bytes32ToString (bytes32 x) constant private returns (string) {
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