pragma solidity ^0.4.17;

contract Owner {
    
    address internal owner;
    
    function Owner() {
        owner = msg.sender;
    }
    
    function getOwner() returns (address){
        return owner;
    }
    
}