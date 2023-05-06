// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./CallMe.sol";

contract TestCallMe is Test {
    address alice = makeAddr("alice");
    CallMeChallenge target;

    function setUp() external {
        vm.createSelectFork(vm.envString("SEPOLIA"));
        target = new CallMeChallenge();
        vm.deal(alice, 10 ether);
    }

    function testCall() external {
        console.log("Komplit?", target.isComplete());
        vm.prank(alice, alice);
        target.callme();
        console.log("Komplit?", target.isComplete());
        assertTrue(target.isComplete());
    }
}
