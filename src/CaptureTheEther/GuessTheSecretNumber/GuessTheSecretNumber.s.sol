// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./GuessTheSecretNumber.sol";

contract ScriptGuessSecret is Script {
    GuessTheSecretNumberChallenge guess;

    function run() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        vm.startBroadcast(vm.envUint("BOB"));
        console.log("Deploy contract");
        guess = new GuessTheSecretNumberChallenge{value: 1 ether}();
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("ALICE"));
        bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;
        for (uint8 i = 0; i < type(uint8).max; i++) {
            if (keccak256(abi.encodePacked(i)) == answerHash) {
                guess.guess{value: 1 ether}(i);
                console.log(i);
                console.log("kumplit?", guess.isComplete());
            }
        }
    }
}
