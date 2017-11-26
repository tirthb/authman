var Main = artifacts.require("./Main.sol");
var EventTest = artifacts.require("./test/EventTest.sol");

module.exports = function(deployer) {
  deployer.deploy(Main);
  deployer.deploy(EventTest);
};
