//separate data and business logic

pragma solidity ^0.4.6;

contract AuthmanData {

  address private owner;

  function AuthmanData() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require (msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
      owner = newOwner;
  }

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

  function logAuthman(string message, address _address) public {
    logAuthman(message, authmanByAddress[_address]);
  }

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

  function updateAuthman(
    address _address, 
    string firstName, 
    string lastName, 
    string mobilePhone, 
    bytes32 claimHash, 
    address updateBy) public onlyOwner returns (uint _index) {

    if(!isAuthman(_address)) {
      AnyException("Invalid address.");
      revert();
    }

    authmanByAddress[_address].firstName = firstName;
    authmanByAddress[_address].lastName = lastName;
    authmanByAddress[_address].mobilePhone = mobilePhone;
    authmanByAddress[_address].claimHash = claimHash;
    authmanByAddress[_address].updateBy = updateBy;
    authmanByAddress[_address].updateDate = now;

    saveAuthman(_address);

    logAuthman("Updated authman:", authmanByAddress[_address]);
    return authmanByAddress[_address].index;
  }

  function createAuthman(
    address _address, 
    string firstName, 
    string lastName, 
    string mobilePhone, 
    address createBy, 
    bytes32 ssnHash, 
    bytes32 claimHash) public onlyOwner returns (uint _index) {

    //new authman
    if (isAuthman(_address)) {
      AnyException("Address in use.");
      revert();
    }

    authmanByAddress[_address].firstName = firstName;
    authmanByAddress[_address].lastName = lastName;
    authmanByAddress[_address].mobilePhone = mobilePhone;
    authmanByAddress[_address].createBy = createBy;
    authmanByAddress[_address].createDate = now;
    authmanByAddress[_address].ssnHash = ssnHash;
    authmanByAddress[_address].index     = authmanIndex.push(_address) - 1;
    authmanByAddress[_address].claimHash = claimHash;

    saveAuthman(_address);

    logAuthman("New authman:", authmanByAddress[_address]);
    return authmanByAddress[_address].index;
  }

  function claimAuthman(
    address _address, 
    bytes32 claimedAuthmanIdHash, 
    string mobilePhone) public onlyOwner {

    //valid credentials
    authmanByAddress[_address].isClaimed = true;
    authmanByAddress[_address].claimedDate = now;
    authmanByAddress[_address].claimedAuthmanIdHash = claimedAuthmanIdHash;
    authmanByAddress[_address].mobilePhone = mobilePhone;
    saveAuthman(_address);

    logAuthman("Claimed authman.", authmanByAddress[_address]);
  }

  function saveAuthman(address _address) private {
    authmanAddressBySsnHash[authmanByAddress[_address].ssnHash] = _address;

    if (authmanByAddress[_address].claimHash[0] > 0) {
      authmanAddressByClaimHash[authmanByAddress[_address].claimHash] = _address;
    }
    if (authmanByAddress[_address].claimedAuthmanIdHash[0] > 0) {
      authmanAddressByAuthmanIdHash[authmanByAddress[_address].claimedAuthmanIdHash] = _address;
    }
  }

  function isAuthman(address authmanAddress)
  public 
  constant
  returns(bool isIndeed) 
  {
    if(authmanIndex.length == 0) return false;
    return (authmanIndex[authmanByAddress[authmanAddress].index] == authmanAddress);
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

  function getAuthmanAddressBySsnHash(bytes32 hash) returns (address _address) {
    return authmanAddressBySsnHash[hash];
  }

  function getSsnHashByAddress(address _address) returns (bytes32 hash) {
    return authmanByAddress[_address].ssnHash;
  }

  function getIsClaimedByAddress(address _address) returns (bool isClaimed) {
    return authmanByAddress[_address].isClaimed;
  }

  function getAuthmanAddressByAuthmanIdHash(bytes32 hash) returns (address _address) {
    return authmanAddressByAuthmanIdHash[hash];
  }

  function getAuthmanAddressByClaimHash(bytes32 hash) returns (address _address) {
    return authmanAddressByClaimHash[hash];
  }

}