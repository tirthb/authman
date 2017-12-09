pragma solidity ^0.4.6;

import "./helper/strings.sol";
import "./helper/myString.sol";
import "./helper/validator.sol";

contract AuthmanCrud {

  using strings for *;
  
  struct Authman {
    uint index;
    string firstName;
    string lastName;
    bytes32 ssnHash;
    bytes32 claimHash;
    string mobilePhone;
    address createBy;
    uint createDate;
    address updateBy;
    uint updateDate;
    bool isClaimed;
    uint claimedDate;
    bytes32 claimedAuthmanIdHash;
  }
  
  mapping(address => Authman) internal authmanByAddress;
  mapping(bytes32 => address) internal authmanAddressBySsnHash;
  mapping(bytes32 => address) internal authmanAddressByClaimHash;
  mapping(bytes32 => address) internal authmanAddressByAuthmanIdHash;

  address[] internal authmanIndex;

  // Used for error handling.
  event AnyException(string message);

  // Used for log.info.
  event Info(string message);

  event InfoHash(string message, bytes32 hash);

  event InfoAuthman1(
    string message, 
    address indexed authmanAddress, 
    uint index, 
    string firstName,
    string lastName,
    bytes32 ssnHash,
    bytes32 claimHash,
    string mobilePhone);

  event InfoAuthman2(
    address createBy,
    uint createDate,
    address updateBy,
    uint updateDate,
    bool isClaimed,
    uint claimedDate,
    bytes32 claimedAuthmanIdHash);

  function logAuthman(string message, Authman authman) internal {
    InfoAuthman1(
      message,
      authmanIndex[authman.index],
      authman.index,
      authman.firstName,
      authman.lastName,
      authman.ssnHash,
      authman.claimHash,
      authman.mobilePhone
      );
    logAuthmanRest(authman);
  }

  function logAuthmanRest(Authman authman) private {
    InfoAuthman2(
      authman.createBy,
      authman.createDate,
      authman.updateBy,
      authman.updateDate,
      authman.isClaimed,
      authman.claimedDate,
      authman.claimedAuthmanIdHash
      );
  }

  function isAuthman(address authmanAddress)
  public 
  constant
  returns(bool isIndeed) 
  {
    if(authmanIndex.length == 0) return false;
    return (authmanIndex[authmanByAddress[authmanAddress].index] == authmanAddress);
  }

  function getAddress(string ssn, string dob) returns (address) {

    //validate ssn
    if (!validator.validateSsn(ssn)) {

      AnyException("SSN is not valid.");
      return;
    }
    //validate dob YYYY-MM-DD
    if (!validator.validateDob(dob)) {

      AnyException("Date of birth is not valid. Should be of the format YYYY-MM-DD");
      return;
    }

    //evaluate sshHash and check if exists
    var hash = createSsnHash(ssn, dob);
    return authmanAddressBySsnHash[hash];
  }

  

  function getAuthman(address _address)
  public 
  constant
  returns(
    uint index,
    string firstName,
    string lastName,
    bytes32 ssnHash,
    bytes32 claimHash,
    string mobilePhone
    )
  {
    if(!isAuthman(_address)) {
      AnyException("Invalid address.");
    }
    return(
      authmanByAddress[_address].index,
      authmanByAddress[_address].firstName,
      authmanByAddress[_address].lastName,
      authmanByAddress[_address].ssnHash,
      authmanByAddress[_address].claimHash,
      authmanByAddress[_address].mobilePhone
      );
  }

  function getAuthman2(address _address)
  public
  constant
  returns(
    address createBy,
    uint createDate,
    address updateBy,
    uint updateDate,
    bool isClaimed,
    uint claimedDate,
    bytes32 claimedAuthmanIdHash
    )
  {
    if(!isAuthman(_address)) {
      AnyException("Invalid address.");
    }
    return(
      authmanByAddress[_address].createBy,
      authmanByAddress[_address].createDate,
      authmanByAddress[_address].updateBy,
      authmanByAddress[_address].updateDate,
      authmanByAddress[_address].isClaimed,
      authmanByAddress[_address].claimedDate,
      authmanByAddress[_address].claimedAuthmanIdHash
      );
  }

  function getAuthmanCount() 
  public
  constant
  returns(uint count)
  {
    return authmanIndex.length;
  }

    /* function getAuthmanAtIndex(uint index)
    public
    constant
    returns(address _address)
    {
      return authmanIndex[index];
      } */


      function saveAuthman(address _address) internal {
        authmanAddressBySsnHash[authmanByAddress[_address].ssnHash] = _address;

        if (authmanByAddress[_address].claimHash[0] > 0) {
          authmanAddressByClaimHash[authmanByAddress[_address].claimHash] = _address;
        }
        if (authmanByAddress[_address].claimedAuthmanIdHash[0] > 0) {
          authmanAddressByAuthmanIdHash[authmanByAddress[_address].claimedAuthmanIdHash] = _address;
        }
      }

      function createClaimHash(address _address, string pin) internal returns (bytes32) {
        return keccak256(myString.strConcat(myString.addressToString(_address), pin));
      }

      function createSsnHash(string ssn, string dob) internal returns (bytes32) {

        //split ssn into 3 parts of 3 chars
        string [] memory ssnArr = new string[](3);
        ssnArr[0] = myString.substring(ssn, 0, 3);
        ssnArr[1] = myString.substring(ssn, 3, 6);
        ssnArr[2] = myString.substring(ssn, 6, 9);

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

    }