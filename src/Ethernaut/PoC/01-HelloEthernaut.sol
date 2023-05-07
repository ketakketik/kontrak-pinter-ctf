// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../01-HelloEthernaut/HelloEthernautFactory.sol";
import "forge-std/Test.sol";

contract HelloEthernaut is Test {
    function test() external {
        vm.createSelectFork(vm.envString('sepolia'));
        Ethernaut ethernaut = new Ethernaut();
        InstanceFactory instance = new InstanceFactory();
        ethernaut.registerLevel(instance);
        console.log('setup ethernaut');
        address alice = makeAddr('alice');
        vm.startPrank(alice, alice);
        address helloethernaut = ethernaut.createLevelInstance(instance);
        Instance hello = Instance(helloethernaut);
        emit log_named_address('hello', address(hello));
        console.log('PoC:');
        console.log('1. check variable password yang bersifat public');
        emit log_named_string('password', hello.password());
        console.log('2. masukan password ke parameter fungsi authenticate()');
        hello.authenticate(hello.password());
        console.log('submit level');
        bool sukses = ethernaut.submitLevelInstance(payable(address(hello)));
        assertTrue(sukses);
    }
}