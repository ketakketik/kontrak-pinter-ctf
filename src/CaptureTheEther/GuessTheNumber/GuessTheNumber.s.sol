// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./GuessTheNumber.sol";

contract ScriptGuessNumber is Script {
    GuessTheNumberChallenge public guess;

    function run() external {
        console.log("Deploy kontrak");
        vm.startBroadcast(vm.envUint("BOB"));
        guess = new GuessTheNumberChallenge{value: 1 ether}();
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("ALICE"));
        guess.guess{value: 1 ether}(42);
        console.log("kumplit?", guess.isComplete());
    }
}
