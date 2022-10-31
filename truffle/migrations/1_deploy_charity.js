const Charity = artifacts.require("Charity");
const addresses = ["0xe0d1E2E390764094040d6bD90A4Cd4F39bb3d256", "0x7360527a708BB34B9270ac78DaF1a7Eba0A46d72"]
module.exports = function (deployer) {
  deployer.deploy(Charity, addresses);
};
