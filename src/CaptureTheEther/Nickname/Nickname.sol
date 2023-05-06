// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// Relevant part of the CaptureTheEther contract.
contract CaptureTheEther {
    mapping(address => bytes32) public nicknameOf;

    function setNickname(bytes32 nickname) public {
        nicknameOf[msg.sender] = nickname;
    }
}

// Challenge contract. You don't need to do anything with this; it just verifies
// that you set a nickname for yourself.
contract NicknameChallenge {
    CaptureTheEther cte;
    address player;

    // Your address gets passed in as a constructor parameter.
    constructor(address _cte, address _player) {
        player = _player;
        cte = CaptureTheEther(_cte);
    }

    // Check that the first character is not null.
    function isComplete() public view returns (bool) {
        return cte.nicknameOf(player)[0] != 0;
    }
}
