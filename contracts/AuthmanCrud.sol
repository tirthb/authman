pragma solidity ^0.4.6;

import "./helper/strings.sol";
import "./helper/myString.sol";
import "./helper/SsnRegex.sol";
import "./helper/DobRegex.sol";
import "./helper/PhoneRegex.sol";
import "./helper/PinRegex.sol";
import "./helper/LowerAlphanumericStartsWithAlphabetRegex.sol";
import "./helper/LowerAlphanumericRegex.sol";

contract AuthmanCrud {

  using strings for *;
  address ssnRegex;
  address dobRegex;
  address phoneRegex;
  address pinRegex;
  address lowerAlphaStartsWithAlphaRegex;
  address lowerAlphaRegex;

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
  
  mapping(address => Authman) private authmanByAddress;
  mapping(bytes32 => address) private authmanAddressBySsnHash;
  mapping(bytes32 => address) private authmanAddressByClaimHash;
  mapping(bytes32 => address) private authmanAddressByAuthmanIdHash;

  address[] private authmanIndex;

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

  function logAuthman(string message, Authman authman) private {
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
    return authmanAddressBySsnHash[hash];
  }

  function createOrUpdateAuthman(
    address _address,
    string firstName, 
    string lastName, 
    string ssn,
    string dob, //YYYY-MM-DD
    string pin, //4 digit
    string mobilePhone //10 digit
    ) 
  public returns (uint index)
  {

    //validate ssn
    if (!validateSsn(ssn)) {
      AnyException("SSN is not valid.");
      return -1;
    }
    //validate dob YYYY-MM-DD
    if (!validateDob(dob)) {
      AnyException("Date of birth is not valid. Should be of the format YYYY-MM-DD");
      return -1;
    }
    //if mobile phone exists, validate phone 10 digits [1-9][0-9]{9}
    if (bytes(mobilePhone).length > 0 && !validatePhone(mobilePhone)) {
      AnyException("Mobile phone is not valid. Should be 10 digits with no other characters.");
      return -1;
    }
    //validate pin 4 digits [0-9]{4}
    if (!validatePin(pin)) {
      AnyException("Pin is not valid. Should be 4 digits.");
      return -1;
    }

    //evaluate sshHash and check if exists
    var hash = createSsnHash(ssn, dob);

    address savedAddress = authmanAddressBySsnHash[hash];

    //if authman exists for the ssn hash
    if (authmanByAddress[savedAddress].ssnHash[0] != 0) {

      //make sure the supplied address is the same as saved address
      if (_address != savedAddress) {
        AnyException("Another address exists for the individual.");
        return -1;
      }

      //make sure the supplied address is authman
      /* if (!isAuthman(_address)) {
        AnyException("Invalid address.");
        return;
        } */

        //authman exists, check if claimed
        //if claimed, throw error
        if (authmanByAddress[savedAddress].isClaimed) {
          AnyException("Authman is claimed. Cannot update Authman.");
          return -1;
        }

        //if not claimed, update Authman
        logAuthman("Authman exists but is not claimed. Updating authman.... Current authman: ", authman);

        authmanByAddress[savedAddress].firstName = firstName;
        authmanByAddress[savedAddress].lastName = lastName;
        authmanByAddress[savedAddress].mobilePhone = mobilePhone;
        authmanByAddress[savedAddress].claimHash = createClaimHash(authmanByAddress[savedAddress].index, pin);
        authmanByAddress[savedAddress].updateBy = msg.sender;
        authmanByAddress[savedAddress].updateDate = now;

        saveAuthman(savedAddress);

        logAuthman("Updated authman:", authman);

        } else {

          //new authman
          if (isAuthman(_address)) {
            AnyException("Address in use.");
            return;
          }

          authmanByAddress[_address].firstName = firstName;
          authmanByAddress[_address].lastName = lastName;
          authmanByAddress[_address].mobilePhone = mobilePhone;

          authmanByAddress[_address].createBy = msg.sender;
          authmanByAddress[_address].createDate = now;
          authmanByAddress[_address].ssnHash = hash;
          authmanByAddress[_address].index     = authmanIndex.push(_address) - 1;
          authmanByAddress[_address].claimHash = createClaimHash(authmanByAddress[_address].index, pin);

          saveAuthman(_address);

          logAuthman("New authman:", newAuthman);
        }

        return authmanByAddress[_address].index;
      }

      //mobile phone is optional as banks may not have this information for current customers
      function createOrUpdateAuthman(
        address _address,
        string firstName, 
        string lastName, 
        string ssn,
        string dob, //YYYY-MM-DD
        string pin, //4 digit (auto generated by banks, when customer is not present)
        ) 
      public returns (uint index)
      {

        return createOrUpdateAuthman(
          _address,
          firstName, 
          lastName, 
          ssn, 
          dob, 
          pin, 
          "" //no mobile phone
          );
      }

      function getAuthman(address _address)
      public 
      constant
      returns(bytes32 userEmail, uint userAge, uint index)
      {
        if(!isAuthman(_address)) {
          AnyException("Invalid address.");
        }
        return(
          authmanByAddress[_address].userEmail, 
          userStructs[userAddress].userAge, 
          userStructs[userAddress].index);
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


      function saveAuthman(address _address) private {
        authmanAddressBySsnHash[authmanByAddress[_address].ssnHash] = _address;

        if (authmanByAddress[_address].claimHash[0] > 0) {
          authmanAddressByClaimHash[authmanByAddress[_address].claimHash] = _address;
        }
        if (authmanByAddress[_address].claimedAuthmanIdHash[0] > 0) {
          authmanAddressByAuthmanIdHash[authmanByAddress[_address].claimedAuthmanIdHash] = _address;
        }
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

    /*
    6 - 20 characers, 
    all lower case, 
    at least one alphabet, 
    numbers are allowed but optional, 
    one period is allowed in the middle but optional
    */

    function validateAuthmanId(string authmanId) private returns (bool) {

      var authIdSlice = authmanId.toSlice();

      if (authIdSlice.len() < 6 || authIdSlice.len() > 20) {
        AnyException("Authman Id should be 6 - 20 characters.");
        return false;
      }

      //split authmanId by period
      var delim = ".".toSlice();
      if (authIdSlice.count(delim) > 1) {
        AnyException("Authman Id can only have one period. Period is optional.");
        return false;
      }

      //lowerAlphaStartsWithAlphaRegex ensures that it is lower case alphanumerci beginning with an alphabet
      //lowerAlphaRegex ensures that it is lower case alphanumerci beginning with an alphabet

      if (lowerAlphaStartsWithAlphaRegex == address(0)) {
        lowerAlphaStartsWithAlphaRegex = new LowerAlphanumericStartsWithAlphabetRegex();
      }

      LowerAlphanumericStartsWithAlphabetRegex id1 = LowerAlphanumericStartsWithAlphabetRegex(lowerAlphaStartsWithAlphaRegex);

      if (authIdSlice.count(delim) == 0) {
        //no period
        return id1.matches(authmanId);

        } else {
          //two parts

          if (lowerAlphaRegex == address(0)) {
            lowerAlphaRegex = new LowerAlphanumericRegex();
          }

          LowerAlphanumericRegex id2 = LowerAlphanumericRegex(lowerAlphaRegex);

          string memory part1 = authIdSlice.split(delim).toString();
          string memory part2 = authIdSlice.split(delim).toString();

          return (id1.matches(part1) && id2.matches(part2));      

        }

      }

      function createClaimHash(bytes32 _address, string pin) private returns (bytes32) {
        return keccak256(myString.strConcat(myString.bytes32ToString(_address), pin));
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


    }