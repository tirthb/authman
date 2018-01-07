pragma solidity ^0.4.6;

import "./AuthmanData.sol";
import "./AuthmanSaveService.sol";
import "./AuthmanClaimService.sol";
import "./AuthmanReadService.sol";

contract AuthmanFactory {
    
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
            data = new AuthmanData();
            LogDataContract(data);
        }

        service = new AuthmanSaveService(data);
        LogServiceContract(service);

        AuthmanData dao = AuthmanData(data);
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