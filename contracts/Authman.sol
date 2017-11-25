pragma solidity ^0.4.11;

import "./helper/strings.sol";
import "./helper/myString.sol";
import "./helper/SsnRegex.sol";
import "./helper/DobRegex.sol";
import "./helper/PhoneRegex.sol";
import "./helper/PinRegex.sol";


contract Main
{

  using strings for *;
  address public ssnRegex;
  address public dobRegex;
  address public phoneRegex;
  address public pinRegex;

  struct Authman {
    bytes32 guid;
    string firstName;
    string lastName;
    uint counter;
    bytes32 ssnHash;
    bytes32 claimHash;
    string mobilePhone;
    string createByName;
    string createById;
    uint createDate;
    string updateByName;
    string updateById;
    uint updateDate;
    bool isClaimed;
    uint claimedDate;
    bytes32 claimedAuthmanIdHash;
    bytes32 previousGuid;
  }

  // Used for error handling.
  event AnyException(string message);

  // Used for log.info.
  event Info(string message);
  
  //key:ssnHash
  mapping(bytes32 => Authman) authmanBySsnHash;
  //key:guid
  mapping(bytes32 => Authman) authmanByGuid;
  //key:counter
  mapping(uint => Authman) authmanByCounter;

  uint counter = 0;

  function createOrUpdateAuthmanGuid(string firstName, 
                                      string lastName, 
                                      string ssn,
                                      string dob, //YYYY-MM-DD
                                      string pin, //4 digit
                                      string mobilePhone, //10 digit
                                      string requestedByName,
                                      string requestedById) public {

    //validate ssn
    if (!validateSsn(ssn)) {

      AnyException("SSN is not valid.");
      return;
    }
    //validate dob YYYY-MM-DD
    if (!validateDob(dob)) {

      AnyException("Date of birth is not valid. Should be of the format YYYY-MM-DD");
      return;
    }
    //validate phone 10 digits [1-9][0-9]{9}
    if (!validatePhone(mobilePhone)) {

      AnyException("Mobile phone is not valid. Should be 10 digits with no other characters.");
      return;
    }
    //validate pin 4 digits [0-9]{4}
    if (!validatePin(pin)) {

      AnyException("Pin is not valid. Should be 4 digits.");
      return;
    }

    //evaluate sshHash and check if exists
    var hash = createSsnHash(ssn, dob);

    Authman memory authman = authmanBySsnHash[hash];

    //if authman exists
    if (authman.guid.length > 0) {
      //authman exists, check if claimed
      //if claimed, throw error
      if (authman.isClaimed) {
        AnyException("Authman is claimed. Cannot create new Authman.");
        return;
      }
      
      //if not claimed, update Authman
      Info("Authman exists but is not claimed. Updating authman ".toSlice().concat(myString.bytes32ToString(authman.guid).toSlice()));

      authman.firstName = firstName;
      authman.lastName = lastName;
      authman.mobilePhone = mobilePhone;
      authman.claimHash = createClaimHash(mobilePhone, pin);
      authman.updateById = requestedById;
      authman.updateByName = requestedByName;
      authman.updateDate = now;
      
      saveAuthman(authman, authman.counter, authman.ssnHash);

    } else {
      //if new
      Authman memory newAuthman;

      newAuthman.firstName = firstName;
      newAuthman.lastName = lastName;
      newAuthman.mobilePhone = mobilePhone;
      newAuthman.claimHash = createClaimHash(mobilePhone, pin);
      newAuthman.createById = requestedById;
      newAuthman.createByName = requestedByName;
      newAuthman.createDate = now;

      if (counter != 0) {
        newAuthman.previousGuid = authmanByCounter[counter].guid;
      }
      counter++;
      newAuthman.counter = counter;
      newAuthman.ssnHash = hash;
      newAuthman.guid = createGuid(newAuthman.ssnHash,newAuthman.counter);
      
      saveAuthman(newAuthman, counter, hash);
    }
  }
  
  function saveAuthman(Authman authman, uint counter1, bytes32 hash) private {
      authmanByCounter[counter1] = authman;
      authmanBySsnHash[hash] = authman;
      authmanByGuid[authman.guid] = authman;
  }

  function validateSsn(string ssn) private returns (bool) {

    //cannot use https://regex101.com/r/rP8wL0/1 ^(?!(000|666|9))\d{3}-(?!00)\d{2}-(?!0000)\d{4}$|^(?!(000|666|9))\d{3}(?!00)\d{2}(?!0000)\d{4}$

    if (ssnRegex == address(0)) {
      ssnRegex = new SsnRegex();
    }

    SsnRegex s = SsnRegex(ssnRegex);
    return s.matches(ssn);

  }

  function validateDob(string dob) private returns (bool) {

    if (dobRegex == address(0)) {
      dobRegex = new DobRegex();
    }

    DobRegex s = DobRegex(dobRegex);
    return s.matches(dob);

  }

  function validatePhone(string phone) private returns (bool) {

    if (phoneRegex == address(0)) {
      phoneRegex = new PhoneRegex();
    }

    PhoneRegex s = PhoneRegex(phoneRegex);
    return s.matches(phone);

  }

  function validatePin(string pin) private returns (bool) {

    if (pinRegex == address(0)) {
      pinRegex = new PinRegex();
    }

    PinRegex s = PinRegex(pinRegex);
    return s.matches(pin);

  }

  //there is no random guid in solidity
  function createGuid(bytes32 hash, uint counter1) private returns (bytes32) {
    string memory guid = myString.bytes32ToString(hash).toSlice().concat(myString.uintToBytes(counter1).toSlice());
    return keccak256(guid);
  }

  function createClaimHash(string phone, string pin) pure private returns (bytes32) {
    return keccak256(myString.strConcat(phone,pin));
  }

  function createSsnHash(string ssn, string dob) private returns (bytes32) {

    //removing dashes from ssn if any
    string memory newSsn = removeDashesFromSsn(ssn);

    //split ssn into 3 parts of 3 chars
    string [] memory ssnArr = new string[](3);
    ssnArr[0] = myString.substring(newSsn, 0, 3);
    ssnArr[1] = myString.substring(newSsn, 3, 6);
    ssnArr[2] = myString.substring(newSsn, 6, 9);

    //split dob by dashes
    var dobSlice = dob.toSlice();
    var delim = "-".toSlice();
    string memory year = dobSlice.split(delim).toString();
    string memory  month = dobSlice.split(delim).toString();
    string memory  day = dobSlice.split(delim).toString();

    string memory pipe = "|";
    string memory tilde = "~";

    //concat them like YYYY|S1~MM|S2~DD|N3
    string memory untilMonth = myString.strConcat(year, pipe, ssnArr[0], tilde, month);
    string memory untilDay = myString.strConcat(untilMonth, pipe, ssnArr[1], day);
    string memory hash = myString.strConcat(untilDay, pipe, ssnArr[2]);
    
    //SSN+DOB keccak256
    return keccak256(hash);
  
  }

  function removeDashesFromSsn(string ssn) private returns (string) {

    //removing dashes from ssn if any
    var s = ssn.toSlice();
    var delim = "-".toSlice();
    string memory newSsn = "";
    for(uint i = 0; i < s.count(delim) + 1; i++) {
        newSsn = myString.strConcat(ssn, s.split(delim).toString());
    }
    return newSsn;

  }

  function getCounter() public view returns (uint) {
    return counter;
  }

}

  /*

  function getLocation(uint8 trailNo) returns (string,uint, uint, uint, string) {
    return (trail[trailNo].name,
              trail[trailNo].locationId,
              trail[trailNo].previousLocationId,
              trail[trailNo].timestamp,
              trail[trailNo].secret);
  }
  */



