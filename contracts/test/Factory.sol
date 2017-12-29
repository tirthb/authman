pragma solidity ^0.4.11;

contract Factory {
    address[] newContracts;
    bytes32[] names;

    // Event generated when creating a cookie
    event LogNewContract(address _contract);

    function createContract (bytes32 name) {
        address newContract = new Contract(name);
        LogNewContract(newContract);
        newContracts.push(newContract);
    } 

    function getName (uint i) {
        Contract con = Contract(newContracts[i]);
        names[i] = con.name();
    }
}

contract Contract {
    bytes32 public name;

    function Contract (bytes32 _name) {
        name = _name;
    }
}