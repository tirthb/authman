pragma solidity ^0.4.6;

import "./AuthmanData.sol";
import "./helper/validator.sol";
import "./helper/util.sol";

contract AuthmanService {

  AuthmanData dao;

  function AuthmanService(address authmanDataAddress) public {
    dao = AuthmanData(authmanDataAddress);
  }

  // Used for error handling.
  event AnyException(bytes32 m);
  event AnyException(bytes32 m1, bytes32 m2);
  event AnyException(bytes32 m1, bytes32 m2, bytes32 m3);

  function createOrUpdateAuthman(
    address _address,
    bytes32 firstName, 
    bytes32 lastName, 
    bytes32 ssn,
    bytes32 dob, //YYYY-MM-DD
    bytes32 pin, //4 digit
    bytes32 mobilePhone //10 digit
    ) 
  public returns (uint index, int8 errorCode)
  {

   //validate ssn
   if (!validator.validateSsnWithEvent(ssn)) {
    return(0, -1);
  }

  //validate dob YYYY-MM-DD
  if (!validator.validateDobWithEvent(dob)) {
    return(0, -1);
  }

  //validate pin 4 digits [0-9]{4}
  if (!validator.validatePinWithEvent(pin)) {
    return(0, -1);
  }

  //if mobile phone exists, validate phone 10 digits [1-9][0-9]{9}
  if (mobilePhone != 0 && !validator.validatePhoneWithEvent(mobilePhone)) {
    return(0, -1);
  }

  //evaluate sshHash and check if exists
  var hash = util.createSsnHash(ssn, dob);

  address savedAddress = dao.getAuthmanAddressBySsnHash(hash);

  bytes32 claimHash = util.createClaimHash(_address, pin);

  //if authman exists for the ssn hash
  if (dao.getSsnHashByAddress(savedAddress)[0] != 0) {

   //make sure the supplied address is the same as saved address
   if (_address != savedAddress) {
    //AnyException("Another address exists for the i","ndividual.");
    return(0, -1);
  }

  //authman exists, check if claimed
  //if claimed, throw error
  if (dao.getIsClaimedByAddress(savedAddress)) {
   //AnyException("Authman is claimed. Cannot updat","e Authman.");
   return(0, -1);
 } 

 //if not claimed, update Authman
 dao.logAuthman("Authman exists but is not claimed. Updating authman.... Current authman: ", savedAddress);

 var _index = dao.updateAuthman(_address, firstName, lastName, mobilePhone, claimHash, tx.origin);
 return (_index, 0);

 } else {

  _index = dao.createAuthman(_address, firstName, lastName, mobilePhone, claimHash, hash, tx.origin);
  return (_index, 0);
}

}

//mobile phone is optional as banks may not have this information for current customers
function createOrUpdateAuthmanNoPhone(
 address _address,
 bytes32 firstName, 
 bytes32 lastName, 
 bytes32 ssn,
 bytes32 dob, //YYYY-MM-DD
 bytes32 pin //4 digit (auto generated by banks, when customer is not present)
 ) 
public returns (uint index, int8 errorCode)
{

 return createOrUpdateAuthman(
  _address,
  firstName, 
  lastName, 
  ssn, 
  dob, 
  pin, 
  0 //no mobile phone
  );
}

//claiming authman from phone
function claimAuthman(
  bytes32 mobilePhone, 
  bytes32 pin, 
  bytes32 claimHash) public returns (int8 errorCode) {

  //validate phone 10 digits [1-9][0-9]{9}
  if (!validator.validatePhoneWithEvent(mobilePhone)) {
    return -1;
  }

  //validate pin 4 digits [0-9]{4}
  if (!validator.validatePinWithEvent(pin)) {
    return -1;
  }

  address _address = dao.getAuthmanAddressByClaimHash(claimHash);

  if (_address == address(0)) {
    //AnyException("Claim hash is not valid. No corr","esponding authman found.");
    return -1;
  }

  if (dao.getIsClaimedByAddress(_address)) {
    //AnyException("Authman is already claimed. Plea","se unclaim first if it belongs t","o you.");
    return -1;
  }

  bytes32 newClaimHash = util.createClaimHash(_address, pin);

  if (newClaimHash != claimHash) {
    //AnyException("Pin is not valid.");
    return -1;
  }

  dao.claimAuthman(_address, mobilePhone);

}

function getAddress(bytes32 ssn, bytes32 dob) constant public returns (address, int8 errorCode) {

  //validate ssn
  if (!validator.validateSsnWithEvent(ssn)) {
    return (address(0), -1);
  }
  //validate dob YYYY-MM-DD
  if (!validator.validateDobWithEvent(dob)) {
    return (address(0), -1);
  }

  //evaluate sshHash and check if exists
  var hash = util.createSsnHash(ssn, dob);
  var _address = dao.getAuthmanAddressBySsnHash(hash);
  return(_address, -1);
}

}