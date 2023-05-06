// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./Secure.sol";

contract TestSecure is Test {
    Setup secure;
    address creator = vm.addr(vm.envUint("CREATOR"));
    address attacker = vm.addr(vm.envUint("ATTACKER"));

    function testSecure() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        vm.deal(attacker, 100 ether);
        secure = new Setup{value: 50 ether}();
        console.log("contract terdeploy di", address(secure));
        vm.startPrank(attacker);
        secure.WETH().deposit{value: 50 ether}();
        secure.WETH().transfer(address(secure), 50 ether);
        assertEq(secure.isSolved(), true);
    }
}
