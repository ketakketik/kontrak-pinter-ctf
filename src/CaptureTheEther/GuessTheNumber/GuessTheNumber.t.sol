// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./GuessTheNumber.sol";

contract TestGuessTheNumber is Test {
    address alice = makeAddr("alice");
    GuessTheNumberChallenge guess;

    function setUp() external {
        vm.createSelectFork(vm.envString("SEPOLIA"));
        vm.deal(alice, 10 ether);
        guess = new GuessTheNumberChallenge{value: 1 ether}();
    }

    function testGuess() external {
        vm.startPrank(alice);
        guess.guess{value: 1 ether}(42);
        assertTrue(guess.isComplete());
    }
}
