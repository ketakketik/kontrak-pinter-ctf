//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

uint256 constant TOTAL_SUPPLY = 1 ether * (10 ** 12);

contract MapleBaCoin is ERC20, Ownable {
    MapleBankon bank;

    constructor() ERC20("MapleBaCoin", "MPBC") {
        _mint(address(owner()), TOTAL_SUPPLY);
    }

    function setBank(address bnk) external onlyOwner {
        bank = MapleBankon(bnk);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(from == address(bank) || to == address(bank));
        super._transfer(from, to, amount);
        bytes memory func = abi.encodeWithSignature("receiveCoin(address,uint256)", from, amount);
        (bool success,) = to.call(func);
        require(success);
    }
}

contract MapleBankon is Ownable {
    MapleBaCoin public immutable mpbc;

    mapping(address => bool) syrupTree;
    mapping(address => uint256) balances;

    constructor(address mpbc_addr) {
        mpbc = MapleBaCoin(mpbc_addr);
    }

    function receiveCoin(address from, uint256 amount) external {
        if (msg.sender != address(mpbc)) {
            return;
        }
        balances[from] += amount;
    }

    function withdraw(uint256 amount) external {
        if (balances[msg.sender] >= amount) {
            mpbc.transfer(msg.sender, amount);
            unchecked {
                if (balances[msg.sender] - amount < balances[msg.sender]) {
                    balances[msg.sender] -= amount;
                } else {
                    balances[msg.sender] = 0;
                }
            }
        }
    }

    function tap() external {
        if (!syrupTree[msg.sender]) {
            syrupTree[msg.sender] = true;
            mpbc.transfer(msg.sender, 1);
        }
    }
}
