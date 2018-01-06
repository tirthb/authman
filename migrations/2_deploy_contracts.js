var Adoption = artifacts.require("Adoption");
var OwnershipFactory = artifacts.require("OwnershipFactory");
var AuthmanFactory = artifacts.require("AuthmanFactory");

module.exports = function(deployer) {
  deployer.deploy(Adoption);
  //deployer.deploy(OwnershipFactory);
  deployer.deploy(AuthmanFactory);
};