// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hello {
    bool public solved = false;

    function solve() public {
        solved = true;
    }
}

contract Setup {
    Hello public hello;

    constructor() {
        hello = new Hello();
    }

    function isSolved() public view returns (bool) {
        return hello.solved();
    }
}
