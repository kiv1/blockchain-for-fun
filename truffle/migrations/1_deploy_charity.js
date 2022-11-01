const Charity = artifacts.require("Charity");
const addresses = ["0xE5F6BC898962749539427b763cB8543501ccE62C", "0x8fCbccDa3734E4435636ee62EDd7c95a478B1E2B"]
module.exports = function (deployer) {
  deployer.deploy(Charity, addresses);
};
