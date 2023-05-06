// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./Nickname.sol";

contract TestNickname is Test {
    address alice = makeAddr("alice");
    CaptureTheEther target;
    NicknameChallenge nickname;

    function setUp() external {
        vm.createSelectFork(vm.envString("SEPOLIA"));
        vm.deal(alice, 10 ether);
        target = new CaptureTheEther();
        nickname = new NicknameChallenge(address(target), alice);
    }

    function testNickname() external {
        vm.startPrank(alice);
        target.setNickname("alice");
        assertTrue(nickname.isComplete());
    }
}
