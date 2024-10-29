// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { console } from "lib/forge-std/src/console.sol";

import { MaivToken } from "../src/token/MaivToken.sol";

contract MaivTokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address ownerAddress = "";
        address initialHolderAddress = "";
        address admin1 = "";
        address admin2 = "";
        address admin3 = "";

        MaivToken maivToken = new MaivToken(ownerAddress, initialHolderAddress, [admin1, admin2, admin3]);

        vm.stopBroadcast();
        console.log("Contract deployed at: ", address(maivToken));
    }
}
