// Fetch the StarNotary contract data from the StarNotary.json file
var StarNotary = artifacts.require("./StarNotary.sol");

// JavaScript export
module.exports = function(deployer) {
    // Deployer is the Truffle wrapper for deploying
    // contracts to the network

    // Deploy the contract to the network
    deployer.deploy(StarNotary);
}