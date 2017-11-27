var Main = artifacts.require("./Main.sol");
var MyTest = artifacts.require("./test/MyTest.sol");
var MyNewTest = artifacts.require("./test/MyNewTest.sol");

module.exports = function(deployer) {
  deployer.deploy(Main);
  deployer.deploy(MyTest);
  deployer.deploy(MyNewTest);
};
