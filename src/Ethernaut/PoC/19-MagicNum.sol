// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../19-MagicNum/MagicNumFactory.sol";
import "forge-std/Test.sol";

contract MagicNumAttack is Test {
    function testMagicNum() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        MagicNumFactory factory = new MagicNumFactory();
        ethernaut.registerLevel(factory);
        address pesulap = makeAddr("pesulap");
        vm.deal(pesulap, 10 ether);
        address addr = ethernaut.createLevelInstance(factory);
        MagicNum num = MagicNum(addr);
        emit log("APA YANG TERJADI KETIKA CONTRACT DIBUAT?");
        emit log(
            "Pertama, seorang pengguna atau kontrak mengirimkan transaksi ke jaringan Ethereum. Transaksi ini berisi data, tetapi tidak ada alamat penerima. Format ini menunjukkan kepada EVM bahwa ini adalah pembuatan kontrak, bukan transaksi pengiriman/panggilan biasa."
        );
        emit log(
            "EV mengkompil kode solidity. Proses ini melibatkan dua tahap, yaitu mengubah kode Solidity menjadi bytecode yang dapat dibaca oleh mesin, dan kemudian mengubah bytecode tersebut menjadi opcodes yang dapat dieksekusi dalam satu tumpukan panggilan (call stack) tunggal. Dengan demikian, EVM memungkinkan kontrak Ethereum untuk dieksekusi secara otomatis dan terdesentralisasi di seluruh jaringan Ethereum"
        );
        emit log(
            "Penting untuk dicatat: bytecode pembuatan kontrak berisi baik 1) kode inisialisasi dan 2) kode runtime aktual kontrak, digabungkan secara berurutan. Artinya, bytecode yang digunakan untuk membuat kontrak Ethereum tidak hanya berisi kode yang akan dijalankan saat kontrak pertama kali dibuat, tetapi juga kode yang akan dieksekusi saat kontrak tersebut berjalan. Kedua kode tersebut digabungkan menjadi satu file bytecode dan dijalankan pada platform Ethereum."
        );
        emit log(
            "Pada saat pembuatan kontrak, EVM hanya mengeksekusi kode inisialisasi hingga mencapai instruksi STOP atau RETURN pertama dalam tumpukan. Pada tahap ini, fungsi konstruktor() kontrak dijalankan, dan kontrak memiliki alamat. Dengan kata lain, pada tahap ini, kontrak sedang dibuat dan diinisialisasi dengan fungsi konstruktor() yang akan menetapkan nilai awal untuk variabel dan parameter yang diperlukan dalam kontrak. Setelah tahap ini selesai, kontrak siap digunakan dan dapat dieksekusi oleh pengguna."
        );
        emit log(
            "Pada saat kode inisialisasi dijalankan, hanya kode runtime yang tersisa di dalam stack. Opcode-opcode ini kemudian disalin ke dalam memori dan dikembalikan ke EVM. Hal ini mengindikasikan bahwa proses inisialisasi dilakukan untuk menyiapkan lingkungan yang dibutuhkan oleh kode runtime agar dapat berjalan dengan baik. Setelah proses inisialisasi selesai, kode runtime yang sudah siap dijalankan akan disalin ke memori dan dikembalikan ke EVM untuk dieksekusi."
        );
        emit log(
            "Pada akhirnya, EVM menyimpan kode yang dikembalikan dan berlebihan ini di penyimpanan keadaan, yang terkait dengan alamat kontrak baru. Ini adalah kode waktu eksekusi yang akan dieksekusi oleh tumpukan dalam semua panggilan masa depan ke kontrak baru. Dalam kata lain, setelah kode kontrak baru dikompilasi dan diuji, EVM akan menyimpan kode tersebut di dalam penyimpanan keadaan dan akan menjadi kode yang akan dieksekusi setiap kali kontrak baru dipanggil."
        );
        bytes memory code = "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";
        address solver;

        assembly {
            solver := create(0, add(code, 0x20), mload(code))
        }
        num.setSolver(solver);
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
        emit log("sejujurnya saya ga paham soal ini wkwkwk");
    }
}
