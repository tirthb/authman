var AuthmanFactory = artifacts.require("./AuthmanFactory.sol");

var zeroAddress = '0x0000000000000000000000000000000000000000';

contract('AuthmanFactory', function(accounts) {
  it("should create a valid new service", function() {
    var factory;
    var serviceAddress;
    var dataAddress;

    //    Get initial balances of first and second account.
    var account_one = accounts[0];
    
    return AuthmanFactory.deployed().then(function(instance) {
      factory = instance;
      return factory.newService({from: account_one});
    }).then(function(instance) {
      console.log("dataAddress: " + JSON.stringify(instance.logs[0].args));
      console.log("serviceAddress: " + JSON.stringify(instance.logs[1].args));
      serviceAddress = instance.logs[1].args.serviceAddress;
      assert.notEqual(serviceAddress, zeroAddress,"Return service address cannot be zero.");
      return factory.getService.call();
      
      
    }).then(function(_serviceAddress) {
      serviceAddress = _serviceAddress;
      assert.notEqual(serviceAddress, zeroAddress, "Factory save service address cannot be zero.");
      return factory.getData.call();
    }).then(function(_dataAddress) {
      dataAddress = _dataAddress;
      assert.notEqual(dataAddress, zeroAddress, "Factory data address cannot be zero.");
      assert.notEqual(dataAddress, serviceAddress, "Data and save service address cannot be equal.");
    });

  });
});
