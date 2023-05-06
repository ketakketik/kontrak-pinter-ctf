// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./Random.sol";

contract TestRandom is Test {
    address alice = vm.addr(vm.envUint("ALICE"));
    Random random;
    Setup setup;

    function setUp() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        setup = new Setup();
        random = Random(address(setup.random()));
    }

    function testGuess() external {
        vm.startPrank(alice, alice);
        random.solve(4);
        assertTrue(setup.isSolved());
    }
}
