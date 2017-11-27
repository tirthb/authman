  pragma solidity ^0.4.15;

  import "../helper/myString.sol";
  import "../helper/strings.sol";

  contract MyTest {
    
    using strings for *;

    event AnyException(string message);
    event Info(string message);
    event LogHash(bytes32 message);

    function testEvent(string s) public returns (bool) {
      if (keccak256(s) == keccak256("titu")) {
        AnyException("Invalid input: titu");
        return false;
      }
      return true;
    }

    function testConcat(string s) public returns (string) {
      var out = myString.strConcat("ABC", s);
      Info(out);
      return out;
    }

    function testSliceConcat(string s) public returns (string) {
      var out = "ABC".toSlice().concat(s.toSlice());
      Info(out);
      return out;
    }

    function testPrintHash(string s) public {
      var out = keccak256(s);
      LogHash(out);
    }

  }