var AuthmanData = artifacts.require("./AuthmanData.sol");
var AuthmanService = artifacts.require("./AuthmanService.sol");
var UserCrud = artifacts.require("./helper/UserCrud.sol");

module.exports = function(deployer) {
  deployer.deploy(AuthmanData);
  deployer.deploy(AuthmanService);
};
