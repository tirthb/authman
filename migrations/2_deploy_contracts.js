var AuthmanDao = artifacts.require("./AuthmanDao.sol");
var AuthmanService = artifacts.require("./AuthmanService.sol");
var UserCrud = artifacts.require("./helper/UserCrud.sol");

module.exports = function(deployer) {
  deployer.deploy(AuthmanDao);
  deployer.deploy(AuthmanService);
};
