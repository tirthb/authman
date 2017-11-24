pragma solidity ^0.4.11;

contract DobRegex {
  struct State {
    bool accepts;
    function (byte) constant internal returns (State memory) func;
  }

  string public constant regex = "[1-2][0-9]{3}\\-[0-1][0-9]\-[0-3][0-9]";

  function s0(byte c) constant internal returns (State memory) {
    c = c;
    return State(false, s0);
  }

  function s1(byte c) constant internal returns (State memory) {
    if (c >= 49 && c <= 50) {
      return State(false, s2);
    }

    return State(false, s0);
  }

  function s2(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57) {
      return State(false, s3);
    }

    return State(false, s0);
  }

  function s3(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57) {
      return State(false, s4);
    }

    return State(false, s0);
  }

  function s4(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57) {
      return State(false, s5);
    }

    return State(false, s0);
  }

  function s5(byte c) constant internal returns (State memory) {
    if (c == 45) {
      return State(false, s6);
    }

    return State(false, s0);
  }

  function s6(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 49) {
      return State(false, s7);
    }

    return State(false, s0);
  }

  function s7(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57) {
      return State(false, s8);
    }

    return State(false, s0);
  }

  function s8(byte c) constant internal returns (State memory) {
    if (c == 45) {
      return State(false, s9);
    }

    return State(false, s0);
  }

  function s9(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 51) {
      return State(false, s10);
    }

    return State(false, s0);
  }

  function s10(byte c) constant internal returns (State memory) {
    if (c >= 48 && c <= 57) {
      return State(true, s11);
    }

    return State(false, s0);
  }

  function s11(byte c) constant internal returns (State memory) {
    // silence unused var warning
    c = c;

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
