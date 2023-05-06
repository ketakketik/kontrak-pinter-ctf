// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./Deploy.sol";

contract ScriptDeploy is Script {
    DeployChallenge target;

    function run() external {
        vm.startBroadcast();
        console.log("Deploy contract");
        target = new DeployChallenge();
        console.log("deployed?", target.isComplete());
    }
}
