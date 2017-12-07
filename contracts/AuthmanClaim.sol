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
    if (!validatePhone(mobilePhone)) {
      AnyException("Mobile phone is not valid. Should be 10 digits with no other characters.");
      return;
    }

    //validate pin 4 digits [0-9]{4}
    if (!validatePin(pin)) {
      AnyException("Pin is not valid. Should be 4 digits.");
      return;
    }

    if (!validateAuthmanId(authmanId)) {
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

    }