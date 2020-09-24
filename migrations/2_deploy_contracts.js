var finalContract = artifacts.require("./Contract.sol");
module.exports = function (deployer) {
    deployer.deploy(finalContract);
};