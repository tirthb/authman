var AuthmanFactory = artifacts.require("./AuthmanFactory.sol");
var AuthmanService = artifacts.require("./AuthmanService.sol");

var zeroAddress = '0x0000000000000000000000000000000000000000';

contract('AuthmanFactory', function(accounts) {

  var factory;
  var serviceAddress;
  var dataAddress;
  var account_one = accounts[0];

  beforeEach('setup contract for each test', function () {

    return AuthmanFactory.deployed().then(function(instance) {
      factory = instance;
      return factory.newService({from: account_one});
    }).then(function(instance) {
      console.log("dataAddress: " + JSON.stringify(instance.logs[0].args));
      console.log("serviceAddress: " + JSON.stringify(instance.logs[1].args));
      serviceAddress = instance.logs[1].args.serviceAddress;
    });

  });

  it("should create a valid new service", function() {

    return factory.getService.call().then(function(_serviceAddress) {
      serviceAddress = _serviceAddress;
      assert.notEqual(serviceAddress, zeroAddress, "Factory save service address cannot be zero.");
      return factory.getData.call();
    }).then(function(_dataAddress) {
      dataAddress = _dataAddress;
      assert.notEqual(dataAddress, zeroAddress, "Factory data address cannot be zero.");
      assert.notEqual(dataAddress, serviceAddress, "Data and save service address cannot be equal.");
    });

  });

  /*it("should create authman with no phone", function() {
    /*
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

    var service = AuthmanService.at(serviceAddress);

    return service.createOrUpdateAuthman('0x1', "titu","bhowmick","123456789","2000-12-31","1234", {from: account_one})
    .then(function(instance) {



    });

    return factory.getService.call().then(function(_serviceAddress) {
      serviceAddress = _serviceAddress;
      assert.notEqual(serviceAddress, zeroAddress, "Factory save service address cannot be zero.");
      return factory.getData.call();
    }).then(function(_dataAddress) {
      dataAddress = _dataAddress;
      assert.notEqual(dataAddress, zeroAddress, "Factory data address cannot be zero.");
      assert.notEqual(dataAddress, serviceAddress, "Data and save service address cannot be equal.");
    });

  });*/

});
