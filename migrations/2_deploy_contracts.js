var Adoption = artifacts.require("Adoption");
var OwnershipFactory = artifacts.require("OwnershipFactory");

module.exports = function(deployer) {
  deployer.deploy(Adoption);
  deployer.deploy(OwnershipFactory);
};