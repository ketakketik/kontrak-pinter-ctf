// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./Hello.sol";

contract TestHello is Test {
    address alice = vm.addr(vm.envUint("ALICE"));
    address bob = vm.addr(vm.envUint("BOB"));
    Setup setup;
    Hello hello;

    function setUp() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        vm.startPrank(bob);
        setup = new Setup();
        hello = Hello(address(setup.hello()));
        vm.stopPrank();
    }

    function testHello() external {
        vm.startPrank(alice);
        hello.solve();
        assertTrue(setup.isSolved());
    }
}
