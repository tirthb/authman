pragma solidity ^0.4.11;

import "./TestDao.sol";

contract TestService {
    
    TestDao dao;
    
    function TestService(address daoAddress) {
        dao = TestDao(daoAddress);
    }
    
    function add(uint _id) {
        dao.add(_id);
    }
}