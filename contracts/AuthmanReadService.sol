pragma solidity ^0.4.6;

import "./AuthmanData.sol";
import "./helper/validator.sol";
import "./helper/util.sol";

contract AuthmanReadService {

  AuthmanData dao;

  function AuthmanReadService(address authmanDataAddress) public {
    dao = AuthmanData(authmanDataAddress);
  }

  // Used for error handling.
  event AnyException(string message);

  function getAddress(bytes32 ssn, bytes32 dob) constant public returns (address) {

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

    //evaluate sshHash and check if exists
    var hash = util.createSsnHash(ssn, dob);
    return dao.getAuthmanAddressBySsnHash(hash);
  }

}