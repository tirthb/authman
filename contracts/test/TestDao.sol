pragma solidity ^0.4.11;

contract TestDao {
    
    address public owner;
    
    uint [] data;
    
    function TestDao() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
    
    function add(uint _id) onlyOwner {
        
        data.push(_id);
    }
}