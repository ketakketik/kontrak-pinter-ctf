// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract secure_enclave {
    event pushhh(string alert_text);

    struct Secret {
        address owner;
        string secret_text;
    }

    mapping(address => Secret) private secrets;

    function set_secret(string memory text) public {
        secrets[msg.sender] = Secret(msg.sender, text);
        emit pushhh(text);
    }

    function get_secret() public view returns (string memory) {
        return secrets[msg.sender].secret_text;
    }
}
