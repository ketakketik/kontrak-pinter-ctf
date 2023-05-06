// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./Hackable.sol";

contract ScriptHackable is Script {
    function run() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        console.log("deploy hackable");
        vm.startBroadcast(vm.envUint("CREATOR"));
        Hackable hackable = new Hackable(0, 1);
        vm.stopBroadcast();
        console.log("hackable terdeploy");
        console.log("waktunya menghacking");
        console.log("done?", hackable.done());
        console.log("winner:", hackable.winner());
        vm.startBroadcast(vm.envUint("HACKER"));
        require(block.number % hackable.mod() == hackable.lastXDigits(), "belom saatnya");
        hackable.cantCallMe();
        console.log("done?", hackable.done());
        console.log("winner:", hackable.winner());
    }
}
