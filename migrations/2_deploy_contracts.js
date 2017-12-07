var AuthmanCrud = artifacts.require("./AuthmanCrud.sol");
var AuthmanSave = artifacts.require("./AuthmanSave.sol");
var AuthmanClaim = artifacts.require("./AuthmanClaim.sol");
var MyTest = artifacts.require("./test/MyTest.sol");
var MyNewTest = artifacts.require("./test/MyNewTest.sol");

module.exports = function(deployer) {
  deployer.deploy(AuthmanCrud);
  deployer.deploy(AuthmanSave);
//  deployer.deploy(AuthmanClaim);
};
