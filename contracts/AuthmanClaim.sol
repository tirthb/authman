pragma solidity ^0.4.6;

import "./AuthmanCrud.sol";

contract AuthmanClaim is AuthmanCrud {

	//claiming authman from phone
  function claimAuthmanId(
    string authmanId,
    string mobilePhone, 
    string pin, 
    bytes32 claimHash) public {

    //validate phone 10 digits [1-9][0-9]{9}
    if (!validator.validatePhone(mobilePhone)) {
      AnyException("Mobile phone is not valid. Should be 10 digits with no other characters.");
      return;
    }

    //validate pin 4 digits [0-9]{4}
    if (!validator.validatePin(pin)) {
      AnyException("Pin is not valid. Should be 4 digits.");
      return;
    }

    if (!validator.validateAuthmanId(authmanId)) {
      return;
    }

    bytes32 authmanIdHash = keccak256(authmanId);

    if (authmanAddressByAuthmanIdHash[authmanIdHash] != address(0)) {
      AnyException("Authman Id already in use. Try new authman Id.");
      return;
    }

    address _address = authmanAddressByClaimHash[claimHash];

    if (_address == address(0)) {
      AnyException("Claim hash is not valid. No corresponding authman found.");
      return;
    }

    if (authmanByAddress[_address].isClaimed) {
      AnyException("Authman is already claimed. Please unclaim first if it belongs to you.");
      return;
    }

    bytes32 newClaimHash = createClaimHash(_address, pin);

    if (newClaimHash != claimHash) {
      AnyException("Mobile phone or pin is not valid.");
      return;
    }    

    //valid credentials
    authmanByAddress[_address].isClaimed = true;
    authmanByAddress[_address].claimedDate = now;
    authmanByAddress[_address].claimedAuthmanIdHash = authmanIdHash;
    authmanByAddress[_address].mobilePhone = mobilePhone;
    saveAuthman(_address);

    logAuthman("Claimed authman.", authmanByAddress[_address]);

  }

}