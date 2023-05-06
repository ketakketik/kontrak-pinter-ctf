// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./Nickname.sol";

contract ScriptNickname is Script {
    CaptureTheEther cte = CaptureTheEther(0x9386267086CF94bB04e408e8012041dc778e996e);
    NicknameChallenge nickname = NicknameChallenge(0xf41dedD453B20Cf0277E30E7C47AE1d83F79d7DF);

    function run() external {
        vm.startBroadcast();
        console.log("kumplit?", nickname.isComplete());
        cte.setNickname("alice");
        console.log("kumplit?", nickname.isComplete());
    }
}
