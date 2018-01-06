pragma solidity ^0.4.6;

import "./AuthmanData.sol";
import "./helper/validator.sol";
import "./helper/util.sol";

contract AuthmanSaveService {

  AuthmanData dao;

  function AuthmanSaveService(address authmanDataAddress) public {
    dao = AuthmanData(authmanDataAddress);
  }

  // Used for error handling.
  event AnyException(string message);

  function createOrUpdateAuthman(
    address _address,
    bytes32 firstName, 
    bytes32 lastName, 
    bytes32 ssn,
    bytes32 dob, //YYYY-MM-DD
    bytes32 pin, //4 digit
    bytes32 mobilePhone //10 digit
    ) 
  public returns (uint index)
  {

     //validate ssn
    if (!validator.validateSsn(ssn)) {
      AnyException("SSN is not valid.");
      revert();
    }

    //validate dob YYYY-MM-DD
    if (!validator.validateDob(dob)) {
      AnyException("Date of birth is not valid. Should be of the format YYYY-MM-DD");
      revert();
    }

    //validate pin 4 digits [0-9]{4}
    if (!validator.validatePin(pin)) {
      AnyException("Pin is not valid. Should be 4 digits.");
      revert();
    }

    //if mobile phone exists, validate phone 10 digits [1-9][0-9]{9}
    if (mobilePhone.length > 0 && !validator.validatePhone(mobilePhone)) {
      AnyException("Mobile phone is not valid. Should be 10 digits with no other characters.");
      revert();
    }

    //evaluate sshHash and check if exists
    var hash = util.createSsnHash(ssn, dob);

    address savedAddress = dao.getAuthmanAddressBySsnHash(hash);

    bytes32 claimHash = util.createClaimHash(savedAddress, pin);

    //if authman exists for the ssn hash
    if (dao.getSsnHashByAddress(savedAddress)[0] != 0) {

     //make sure the supplied address is the same as saved address
     if (_address != savedAddress) {
      AnyException("Another address exists for the individual.");
      revert();
    }

    //authman exists, check if claimed
    //if claimed, throw error
    if (dao.getIsClaimedByAddress(savedAddress)) {
     AnyException("Authman is claimed. Cannot update Authman.");
     revert();
   } 

   //if not claimed, update Authman
   dao.logAuthman("Authman exists but is not claimed. Updating authman.... Current authman: ", savedAddress);

   return dao.updateAuthman(savedAddress, firstName, lastName, mobilePhone, claimHash, tx.origin);

   } else {

    return dao.createAuthman(_address, firstName, lastName, mobilePhone, tx.origin, hash, claimHash);
  }

}

//mobile phone is optional as banks may not have this information for current customers
function createOrUpdateAuthman(
 address _address,
 bytes32 firstName, 
 bytes32 lastName, 
 bytes32 ssn,
 bytes32 dob, //YYYY-MM-DD
 bytes32 pin //4 digit (auto generated by banks, when customer is not present)
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

}