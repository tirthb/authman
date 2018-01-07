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

contract Dao is Owner{
    
    uint [] data;
    
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
    
    function get(uint _index) returns (uint) {
        return data[_index];
    }
    
}

contract Service is Owner {
    
    Dao dao;
    
    function Service(address daoAddress) {
        dao = Dao(daoAddress);
    }
    
    function add(uint _id) {
        dao.add(_id);
    }
    
}

contract OwnershipFactory is Owner {
    
    address private service;
    address private data;

    event LogDataContract(address dataAddress);
    event LogServiceContract(address serviceAddress);
    
    function newService() public returns(address serviceContract)
    {
        if (service != address(0)) {
            return service;
        }
        
        if (data == address(0)) {
            data = new Dao();
            LogDataContract(data);
        }
        
        service = new Service(data);
        LogServiceContract(service);

        Dao dao = Dao(data);
        dao.transferOwnership(service);

        return service;
    }
    
    function getData() returns (address _data) {
        return data;
    }
    
    function getService() returns (address _service) {
        return service;
    }
    
}