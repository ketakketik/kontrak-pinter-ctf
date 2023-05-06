// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./Random.sol";

contract ScriptRandom is Script {
    function run() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        console.log("deploy contract");
        vm.startBroadcast(vm.envUint("BOB"));
        Setup setup = new Setup();
        Random random = Random(address(setup.random()));
        console.log("kumplit?", setup.isSolved());
        vm.stopBroadcast();
        console.log("solve ctf");
        vm.startBroadcast(vm.envUint("ALICE"));
        random.solve(4);
        console.log("kumplit?", setup.isSolved());
    }
}
