pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthmanFactory.sol";
import "../contracts/helper/ErrorProxy.sol";

contract TestAuthmanFactory {
	AuthmanFactory factory = AuthmanFactory(DeployedAddresses.AuthmanFactory());
	address serviceAddress;
	address dataAddress;

	function beforeAll() {
		serviceAddress = factory.newService();
	}

	// Testing the newService() function
	function testNewService() public {
		
		Assert.isNotZero(serviceAddress, "Return service address cannot be zero.");
		Assert.isNotZero(factory.getService(), "Factory service address cannot be zero.");
		Assert.isNotZero(factory.getData(), "Factory data address cannot be zero.");
		Assert.notEqual(factory.getData(), factory.getService(), "Data and service address cannot be equal.");

	}

	// Testing the service.createOrUpdateAuthman() function
	function testServiceCreateNoPhone() public {
		
		AuthmanSaveService service = AuthmanSaveService(serviceAddress);
		uint _index = service.createOrUpdateAuthman(0x1, "titu","bhowmick","123456789","2000-12-31","1234");

		dataAddress = factory.getData();

		AuthmanData dao = AuthmanData(dataAddress);
		address authmanAddress = dao.getAuthmanByIndex(_index);
		Assert.isNotZero(authmanAddress, "Authman address cannot be zero.");

		verifyAuthmanByAddress(true, false, authmanAddress, _index);
		verifyAuthman2ByAddress(true, authmanAddress);

	}

	// Testing the service.createOrUpdateAuthman() function
	function testServiceCreateWithPhone() public {
		
		AuthmanSaveService service = AuthmanSaveService(serviceAddress);
		uint _index = service.createOrUpdateAuthman(0x2, "titu","bhowmick","223456789","2000-12-31","1234","4085059233");

		dataAddress = factory.getData();

		AuthmanData dao = AuthmanData(dataAddress);
		address authmanAddress = dao.getAuthmanByIndex(_index);
		Assert.isNotZero(authmanAddress, "Authman address cannot be zero.");

		verifyAuthmanByAddress(true, true, authmanAddress, _index);
		verifyAuthman2ByAddress(true, authmanAddress);

	}

	// Testing the service.createOrUpdateAuthman() function
	function testServiceUpdateWithPhone() public {
		
		AuthmanSaveService service = AuthmanSaveService(serviceAddress);
		uint _index = service.createOrUpdateAuthman(0x1, "titu","bhowmick","123456789","2000-12-31","1234","4085059233");

		dataAddress = factory.getData();

		AuthmanData dao = AuthmanData(dataAddress);
		address authmanAddress = dao.getAuthmanByIndex(_index);
		Assert.isNotZero(authmanAddress, "Authman address cannot be zero.");

		verifyAuthmanByAddress(true, true, authmanAddress, _index);
		verifyAuthman2ByAddress(false, authmanAddress);

	}

	function verifyAuthmanByAddress(bool create, bool phone, address authmanAddress, uint _index) private {

		AuthmanData dao = AuthmanData(dataAddress);
		var (index,firstName, lastName, ssnHash, claimHash, mobilePhone) = dao.getAuthman(authmanAddress);

		if (create) {
			Assert.equal(index, _index, "Index should be same in authman object as the index of authmanIndex array in AuthmanData.");
			Assert.equal(firstName, "titu", "authman.firstName should match with the supplied firstName.");
			Assert.equal(lastName, "bhowmick", "authman.lastName should match with the supplied lastName.");
			Assert.isNotZero(ssnHash, "Ssnhash cannot be zero.");
			Assert.isNotZero(claimHash, "Claimhash cannot be zero.");
			if (phone) {
				Assert.equal(mobilePhone, "4085059233", "authman.mobilePhone should match with the supplied mobile phone.");
			}
		}

	}

	function verifyAuthman2ByAddress(bool create, address authmanAddress) private {

		AuthmanData dao = AuthmanData(dataAddress);
		var (createBy, createDate, updateBy, updateDate, isClaimed, claimedDate) = dao.getAuthman2(authmanAddress);


		if (create) {
			Assert.equal(createBy, tx.origin, "authman.createBy should match with tx.origin.");

			//we cannot estimate the exact time of the block timestamp, but we can assume it to be creted within the past 10 minutes
			Assert.isAtLeast(createDate, (now - 600), "authman.createDate should be within 10 minutes.");

			Assert.isZero(updateBy, "authman.updateBy should be empty.");
			Assert.isZero(updateDate, "authman.updateDate should be empty.");
			Assert.isFalse(isClaimed, "authman.isClaimed should be false.");
			Assert.isZero(claimedDate, "authman.claimedDate should be empty.");
		} else {
			Assert.equal(updateBy, tx.origin, "authman.updateBy should match with tx.origin.");

			//we cannot estimate the exact time of the block timestamp, but we can assume it to be creted within the past 10 minutes
			Assert.isAtLeast(updateDate, (now - 600), "authman.updateDate should be within 10 minutes.");

			Assert.isFalse(isClaimed, "authman.isClaimed should be false.");
			Assert.isZero(claimedDate, "authman.claimedDate should be empty.");
		}

	}

	// Testing the Dao.add() function, should fail
	// http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
	/* function testDaoCreate() public {

    
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