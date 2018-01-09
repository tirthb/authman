pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/test/OwnershipFactory.sol";
import "../contracts/helper/ErrorProxy.sol";

contract TestOwnershipFactory {
	OwnershipFactory factory = OwnershipFactory(DeployedAddresses.OwnershipFactory());
	address serviceAddress;

	/* function beforeAll() {
    serviceAddress = factory.newService();
  }

	// Testing the newService() function
	function testNewService() public {
		
		Assert.isNotZero(serviceAddress, "Return service address cannot be zero.");
		Assert.isNotZero(factory.getService(), "Factory service address cannot be zero.");
		Assert.isNotZero(factory.getData(), "Factory data address cannot be zero.");
		Assert.notEqual(factory.getData(), factory.getService(), "Data and service address cannot be equal.");

	}

	// Testing the Service.add() function
	function testServiceAdd() public {
		
		Service service = Service(serviceAddress);
		service.add(1);

		Dao dao = Dao(factory.getData());
		Assert.equal(dao.get(0), 1, "Service contract should be able to save data in Dao contract.");
	}

	// Testing the Dao.add() function, should fail
	// http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
	function testDaoAdd() public {

    
		Dao dao = Dao(factory.getData());
		ErrorProxy proxy = new ErrorProxy(address(dao)); //set Thrower as the contract to forward requests to. The target.

		//prime the proxy.
    Dao(address(proxy)).add(1);
    //execute the call that is supposed to throw.
    //r will be false if it threw. r will be true if it didn't.
    //make sure you send enough gas for your contract method.
    bool r = proxy.execute.gas(300000)();

    Assert.isFalse(r, "Should be false, as it should throw");
	} */


}