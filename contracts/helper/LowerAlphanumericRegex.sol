pragma solidity ^0.4.11;

contract LowerAlphanumericRegex {
  struct State {
    bool accepts;
    function (byte) constant internal returns (State memory) func;
  }

  string public constant regex = "[a-z0-9]+";

  function s0(byte c) constant internal returns (State memory) {
    c = c;
    return State(false, s0);
  }

  function s1(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57 || c >= 97 && c <= 122) {
      return State(true, s2);
    }

    return State(false, s0);
  }

  function s2(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57 || c >= 97 && c <= 122) {
      return State(true, s3);
    }

    return State(false, s0);
  }

  function s3(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57 || c >= 97 && c <= 122) {
      return State(true, s3);
    }

    return State(false, s0);
  }

  function matches(string input) constant returns (bool) {
    var cur = State(false, s1);

    for (uint i = 0; i < bytes(input).length; i++) {
      var c = bytes(input)[i];

      cur = cur.func(c);
    }

    return cur.accepts;
  }
}
