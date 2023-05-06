// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./GuessTheNewNumber.sol";

contract TestGuessNewNumber is Test {
    GuessTheNewNumberChallenge guess;
    address alice = vm.addr(vm.envUint("ALICE"));

    function setUp() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        guess = new GuessTheNewNumberChallenge{value: 1 ether}();
    }

    function testGuess() external {
        vm.startPrank(alice);
        uint8 n = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
        guess.guess{value: 1 ether}(n);
        assertTrue(guess.isComplete());
    }
}
