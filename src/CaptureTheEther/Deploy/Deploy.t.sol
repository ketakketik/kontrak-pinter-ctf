// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./Deploy.sol";

contract TestDeploy is Test {
    DeployChallenge target;

    function testDeploy() external {
        vm.createSelectFork(vm.envString("SEPOLIA"));
        target = new DeployChallenge();
        console.log("kontrak terdeploy");
        assertTrue(target.isComplete());
    }
}
