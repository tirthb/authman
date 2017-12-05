var AuthmanCrud = artifacts.require("./AuthmanCrud.sol");
var MyTest = artifacts.require("./test/MyTest.sol");
var MyNewTest = artifacts.require("./test/MyNewTest.sol");

module.exports = function(deployer) {
  deployer.deploy(AuthmanCrud);
  deployer.deploy(MyTest);
  deployer.deploy(MyNewTest);
};
