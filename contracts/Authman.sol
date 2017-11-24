//TODO: remove warnings

pragma solidity ^0.4.6;

import "./helper/strings.sol";
import "./helper/MyStringUtils.sol";
import "./helper/SsnRegex.sol";
import "./helper/DobRegex.sol";


contract Main
{
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

  using strings for *;
  
  function createOrUpdateAuthmanGuid(string firstName, 
                                      string lastName, 
                                      string ssn,
                                      string dob, //YYYY-MM-DD
                                      string pin, //4 digit
                                      string mobilePhone,
                                      string requestedByName,
                                      string requestedById) {

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

    //evaluate sshHash and check if exists
    var hash = createSsnHash(ssn, dob);

    Authman authman = authmanBySsnHash[hash];

    //if authman exists
    if (authman.guid.length > 0) {
      //authman exists, check if claimed
      //if claimed, throw error
      if (authman.isClaimed) {
        AnyException("Authman is claimed. Cannot create new Authman.");
        return;
      }
      
      //if not claimed, update Authman
      Info("Authman exists but is not claimed. Updating authman ".toSlice().concat(MyStringUtils.bytes32ToString(authman.guid).toSlice()));

      authman.firstName = firstName;
      authman.lastName = lastName;
      authman.mobilePhone = mobilePhone;
      authman.updateById = requestedById;
      authman.updateByName = requestedByName;
      authman.updateDate = now;

    } else {
      //if new
      Authman memory newAuthman;

      newAuthman.firstName = firstName;
      newAuthman.lastName = lastName;
      newAuthman.mobilePhone = mobilePhone;
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
      
      authmanByCounter[counter] = newAuthman;
      authmanBySsnHash[hash] = newAuthman;
      authmanByGuid[newAuthman.guid] = newAuthman;
    }
    
  }

  function validateSsn(string ssn) private returns (bool) {

    //cannot use https://regex101.com/r/rP8wL0/1 ^(?!(000|666|9))\d{3}-(?!00)\d{2}-(?!0000)\d{4}$|^(?!(000|666|9))\d{3}(?!00)\d{2}(?!0000)\d{4}$

    /*
    TODO: to remove later. saving it for reference. We can use constant as static, so no need of instance
    address public ssnRegex; (declared at the top)
    if (ssnRegex == address(0)) {
      ssnRegex = new SsnRegex();
    }
    */

    return SsnRegex.matches(ssn);

  }

  function validateDob(string dob) private returns (bool) {

     return DobRegex.matches(dob);

  }

  //there is no random guid in solidity
  function createGuid(bytes32 hash, uint counter) private returns (bytes32) {
    string memory guid = MyStringUtils.bytes32ToString(hash).toSlice().concat(MyStringUtils.uintToBytes(counter).toSlice());
    return keccak256(guid);
  }

  function createSsnHash(string ssn, string dob) returns (bytes32) {

    //removing dashes from ssn if any
    string memory newSsn = removeDashesFromSsn(ssn);

    //split ssn into 3 parts of 3 chars
    string memory s1 = MyStringUtils.substring(newSsn, 0, 3);
    string memory s2 = MyStringUtils.substring(newSsn, 3, 6);
    string memory n3 = MyStringUtils.substring(newSsn, 6, 9);

    //split dob by dashes
    var dobSlice = dob.toSlice();
    var delim = "-".toSlice();
    var year = dobSlice.split(delim).toString();
    var month = dobSlice.split(delim).toString();
    var day = dobSlice.split(delim).toString();

    var pipe = "|";
    var tilde = "~";

    //concat them like YYYY|S1~MM|S2~DD|N3
    string memory untilMonth = MyStringUtils.strConcat(year, pipe, s1, tilde, month);
    string memory untilDay = MyStringUtils.strConcat(tillMonth, pipe, s2, day);
    string memory hash = MyStringUtils.strConcat(untilDay, pipe, n3);
    
    //SSN+DOB keccak256
    return keccak256(hash);
  
  }

  function removeDashesFromSsn(string ssn) private returns (string) {

    //removing dashes from ssn if any
    var s = ssn.toSlice();
    var delim = "-".toSlice();
    var newSsn = "".toSlice();
    for(uint i = 0; i < (s.count(delim) + 1); i++) {
        newSsn.concat(s.split(delim));
    }

    return newSsn.toString();
  }

  function getCounter() returns (uint) {
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



