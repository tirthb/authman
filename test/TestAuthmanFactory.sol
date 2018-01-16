pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthmanFactory.sol";
import "../contracts/helper/ErrorProxy.sol";

contract TestAuthmanFactory {
	AuthmanFactory factory = AuthmanFactory(DeployedAddresses.AuthmanFactory());
	address serviceAddress;
	address dataAddress;
	bytes32 _claimHash;

	function beforeAll() {
		serviceAddress = factory.newService();
	}

	// Testing the newService() function
	function testNewService() public {
		
		Assert.isNotZero(serviceAddress, "Return service address cannot be zero.");
		Assert.isNotZero(factory.getService(), "Factory save service address cannot be zero.");
		Assert.isNotZero(factory.getData(), "Factory data address cannot be zero.");
		Assert.notEqual(factory.getData(), factory.getService(), "Data and save service address cannot be equal.");

	}

	// Testing the service.createOrUpdateAuthman() function
	function testServiceCreateNoPhone() public {
		
		AuthmanService service = AuthmanService(serviceAddress);
		var (_index, errorCode) = service.createOrUpdateAuthman(0x1, "titu","bhowmick","123456789","2000-12-31","1234");

		if (dataAddress == address(0)) {
			dataAddress = factory.getData();
		}

		AuthmanData dao = AuthmanData(dataAddress);
		address authmanAddress = dao.getAuthmanByIndex(_index);
		Assert.isNotZero(authmanAddress, "Authman address cannot be zero.");

		verifyAuthmanByAddress(true, false, authmanAddress, _index);
		verifyAuthman2ByAddress(true, authmanAddress);

	}

	// Testing the service.createOrUpdateAuthman() function
	function testServiceCreateWithPhone() public {
		
		AuthmanService service = AuthmanService(serviceAddress);
		var (_index, errorCode) = service.createOrUpdateAuthman(0x2, "titu","bhowmick","223456789","2000-12-31","1234","4081234567");

		if (dataAddress == address(0)) {
			dataAddress = factory.getData();
		}

		AuthmanData dao = AuthmanData(dataAddress);
		address authmanAddress = dao.getAuthmanByIndex(_index);
		Assert.isNotZero(authmanAddress, "Authman address cannot be zero.");

		verifyAuthmanByAddress(true, true, authmanAddress, _index);
		verifyAuthman2ByAddress(true, authmanAddress);

	}

	// Testing the service.createOrUpdateAuthman() function
	function testServiceUpdateWithPhone() public {
		
		AuthmanService service = AuthmanService(serviceAddress);
		var (_index, errorCode) = service.createOrUpdateAuthman(0x1, "titu","bhowmick","123456789","2000-12-31","1234","4081234567");

		if (dataAddress == address(0)) {
			dataAddress = factory.getData();
		}

		AuthmanData dao = AuthmanData(dataAddress);
		address authmanAddress = dao.getAuthmanByIndex(_index);
		Assert.isNotZero(authmanAddress, "Authman address cannot be zero.");

		verifyAuthmanByAddress(true, true, authmanAddress, _index);
		verifyAuthman2ByAddress(false, authmanAddress);

	}

	// Testing the service.claimAuthman() function
	function testServiceClaim() public {

		bytes32 pin = "1235";

		AuthmanService service = AuthmanService(serviceAddress);
		var (_index, errorCode) = service.createOrUpdateAuthman(0x3, "titu","bhowmick","323456789","2000-12-31", pin,"4081234567");
		
		if (dataAddress == address(0)) {
			dataAddress = factory.getData();
		}

		AuthmanData dao = AuthmanData(dataAddress);
		address authmanAddress = dao.getAuthmanByIndex(_index);
		verifyAuthmanByAddress(true, true, authmanAddress, _index);

		bytes32 newMobilePhone = "2081234567";

		service.claimAuthman(newMobilePhone, pin, _claimHash);
		verifyAuthmanClaimByAddress(authmanAddress, newMobilePhone);
		verifyAuthman2ClaimByAddress(authmanAddress);

	}

	function verifyAuthmanByAddress(bool create, bool phone, address authmanAddress, uint _index) private {

		AuthmanData dao = AuthmanData(dataAddress);
		var (index,firstName, lastName, ssnHash, claimHash, mobilePhone) = dao.getAuthman(authmanAddress);

		if (create) {
			_claimHash = claimHash;
			Assert.equal(index, _index, "Index should be same in authman object as the index of authmanIndex array in AuthmanData.");
			Assert.equal(firstName, "titu", "authman.firstName should match with the supplied firstName.");
			Assert.equal(lastName, "bhowmick", "authman.lastName should match with the supplied lastName.");
			Assert.isNotZero(ssnHash, "Ssnhash cannot be zero.");
			Assert.isNotZero(claimHash, "Claimhash cannot be zero.");
			if (phone) {
				Assert.equal(mobilePhone, "4081234567", "authman.mobilePhone should match with the supplied mobile phone.");
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

		function verifyAuthmanClaimByAddress(address authmanAddress, bytes32 _mobilePhone) private {

			AuthmanData dao = AuthmanData(dataAddress);
			var (index,firstName, lastName, ssnHash, claimHash, mobilePhone) = dao.getAuthman(authmanAddress);

			Assert.equal(mobilePhone, _mobilePhone, "authman.mobilePhone should match with the supplied mobile phone.");
		}

		function verifyAuthman2ClaimByAddress(address authmanAddress) private {

			AuthmanData dao = AuthmanData(dataAddress);
			var (createBy, createDate, updateBy, updateDate, isClaimed, claimedDate) = dao.getAuthman2(authmanAddress);

			Assert.isAtLeast(claimedDate, (now - 600), "authman.claimedDate should be within 10 minutes.");
			Assert.isTrue(isClaimed, "authman.isClaimed should be false.");

		}

		// Testing the AuthmanData.createAuthman() function, should fail as it is owned by service
		// http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
		function testDataCreateError() public {

			if (dataAddress == address(0)) {
				dataAddress = factory.getData();
			}

			AuthmanData dao = AuthmanData(dataAddress);
			ErrorProxy proxy = new ErrorProxy(address(dao)); //set Thrower as the contract to forward requests to. The target.

			//prime the proxy.
			AuthmanData(address(proxy)).createAuthman(0x1,"titu","bhowmick","123456789",0,0,tx.origin);
			//execute the call that is supposed to throw.
			//r will be false if it threw. r will be true if it didn't.
			//make sure you send enough gas for your contract method.
			bool r = proxy.execute.gas(300000)();

			Assert.isFalse(r, "Should be false, as it should throw");
		}

		// Testing the AuthmanData.updateAuthman() function, should fail as it is owned by service
		// http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
		function testDataUpdateError() public {

			if (dataAddress == address(0)) {
				dataAddress = factory.getData();
			}

			AuthmanData dao = AuthmanData(dataAddress);
			ErrorProxy proxy = new ErrorProxy(address(dao)); //set Thrower as the contract to forward requests to. The target.

			//prime the proxy.
			AuthmanData(address(proxy)).updateAuthman(0x1,"titu","bhowmick","123456789",0,tx.origin);
			//execute the call that is supposed to throw.
			//r will be false if it threw. r will be true if it didn't.
			//make sure you send enough gas for your contract method.
			bool r = proxy.execute.gas(300000)();

			Assert.isFalse(r, "Should be false, as it should throw");
		}

		// Testing the AuthmanData.claimAuthman() function, should fail as it is owned by service
		// http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
		function testDataClaimError() public {

			if (dataAddress == address(0)) {
				dataAddress = factory.getData();
			}

			AuthmanData dao = AuthmanData(dataAddress);
			ErrorProxy proxy = new ErrorProxy(address(dao)); //set Thrower as the contract to forward requests to. The target.

			//prime the proxy.
			AuthmanData(address(proxy)).claimAuthman(0x1,"4081234567");
			//execute the call that is supposed to throw.
			//r will be false if it threw. r will be true if it didn't.
			//make sure you send enough gas for your contract method.
			bool r = proxy.execute.gas(300000)();

			Assert.isFalse(r, "Should be false, as it should throw");
		}


	}