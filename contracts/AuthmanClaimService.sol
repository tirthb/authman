pragma solidity ^0.4.6;

import "./AuthmanData.sol";
import "./helper/myString.sol";
import "./helper/validator.sol";
import "./helper/util.sol";

contract AuthmanClaimService {

  AuthmanData dao;

  function AuthmanClaimService(address authmanDataAddress) public {
    dao = AuthmanData(authmanDataAddress);
  }

  // Used for error handling.
  event AnyException(string message);

  //claiming authman from phone
  function claimAuthmanId(
    bytes32 authmanId,
    bytes32 mobilePhone, 
    bytes32 pin, 
    bytes32 claimHash) public {

    //validate phone 10 digits [1-9][0-9]{9}
    if (!validator.validatePhone(mobilePhone)) {
      AnyException("Mobile phone is not valid. Should be 10 digits with no other characters.");
      revert();
    }

    //validate pin 4 digits [0-9]{4}
    if (!validator.validatePin(pin)) {
      AnyException("Pin is not valid. Should be 4 digits.");
      revert();
    }

    if (!validator.validateAuthmanId(authmanId)) {
      revert();
    }

    bytes32 authmanIdHash = keccak256(authmanId);

    if (dao.getAuthmanAddressByAuthmanIdHash(authmanIdHash) != address(0)) {
      AnyException("Authman Id already in use. Try new authman Id.");
      revert();
    }

    address _address = dao.getAuthmanAddressByClaimHash(claimHash);

    if (_address == address(0)) {
      AnyException("Claim hash is not valid. No corresponding authman found.");
      revert();
    }

    if (dao.getIsClaimedByAddress(_address)) {
      AnyException("Authman is already claimed. Please unclaim first if it belongs to you.");
      revert();
    }

    bytes32 newClaimHash = util.createClaimHash(_address, pin);

    if (newClaimHash != claimHash) {
      AnyException("Pin is not valid.");
      revert();
    }    

    dao.claimAuthman(_address, authmanIdHash, mobilePhone);

  }

}