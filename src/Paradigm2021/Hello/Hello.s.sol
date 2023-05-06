// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./Hello.sol";

contract ScriptHello is Script {
    function run() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        vm.startBroadcast(vm.envUint("BOB"));
        console.log("deploy contract Setup");
        Setup setup = new Setup();
        Hello hello = Hello(address(setup.hello()));
        vm.stopBroadcast();
        console.log("saatnya menghacking");
        vm.startBroadcast(vm.envUint("ALICE"));
        console.log("kumplit?", setup.isSolved());
        hello.solve();
        console.log("kumplit?", setup.isSolved());
    }
}
