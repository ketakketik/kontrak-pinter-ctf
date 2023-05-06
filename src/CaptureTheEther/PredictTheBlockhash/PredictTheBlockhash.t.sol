// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "./PredictTheBlockhash.sol";

contract TestPredictTheBlockhash is Test {
    PredictTheBlockHashChallenge predict;
    address alice = vm.addr(vm.envUint("ALICE"));

    function testPredict() external {
        vm.createSelectFork(vm.envString("ANVIL"));
        predict = new PredictTheBlockHashChallenge{value: 1 ether}();
        vm.startPrank(alice, alice);
        bytes32 m = 0;
        console.log(block.number);
        predict.lockInGuess{value: 1 ether}(m);
        vm.roll(block.number + 400);
        predict.settle();
        assertTrue(predict.isComplete());
    }
}
