// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./GuessTheSecretNumber.sol";

contract TestGuessTheSecretNumber is Test {
    GuessTheSecretNumberChallenge secret;
    address alice = makeAddr("alice");

    function setUp() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        vm.deal(alice, 10 ether);
        secret = new GuessTheSecretNumberChallenge{value: 1 ether}();
    }

    function testGuessSecret() external {
        bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;
        for (uint8 i = 0; i < 255; i++) {
            if (keccak256(abi.encodePacked(i)) == answerHash) {
                vm.startPrank(alice);
                secret.guess{value: 1 ether}(i);
            }
        }
        assertEq(secret.isComplete(), true);
    }
}
