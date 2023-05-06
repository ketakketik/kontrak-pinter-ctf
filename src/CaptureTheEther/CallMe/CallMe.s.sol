// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./CallMe.sol";

contract ScriptCallMe is Script {
    CallMeChallenge target = CallMeChallenge(0xB766d1498C01b3920B355fc2ca326b3424Bfb31A);

    function run() external {
        vm.startBroadcast();
        console.log("kumplit?", target.isComplete());
        target.callme();
        console.log("kumplit?", target.isComplete());
    }
}
