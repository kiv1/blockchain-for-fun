const Charity = artifacts.require("Charity");
const addresses = ["0x9FA4912Ce7b2Dbe22a2200FA6cd67BeAAc33b404", "0x42bB850EDA1Ef3677a813Af68A863E843406A926", "0x2dfbff8A0F38F5701BaA84B5Dda4eDfb2a062327"]
module.exports = function (deployer) {
  deployer.deploy(Charity, addresses);
};
