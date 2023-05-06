// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ERC20Like {
    function transfer(address dst, uint256 qty) external returns (bool);
    function transferFrom(address src, address dst, uint256 qty) external returns (bool);
    function approve(address dst, uint256 qty) external returns (bool);

    function balanceOf(address who) external view returns (uint256);
}

contract TokenModule {
    function deposit(ERC20Like token, address from, uint256 amount) public {
        token.transferFrom(from, address(this), amount);
    }

    function withdraw(ERC20Like token, address to, uint256 amount) public {
        token.transfer(to, amount);
    }
}

contract Wallet {
    address public owner = msg.sender;

    mapping(address => bool) _allowed;
    mapping(address => bool) _operators;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrOperators() {
        require(msg.sender == owner || _operators[msg.sender]);
        _;
    }

    function allowModule(address module) public onlyOwner {
        _allowed[module] = true;
    }

    function disallowModule(address module) public onlyOwner {
        _allowed[module] = false;
    }

    function addOperator(address) public onlyOwner {
        _operators[owner] = true;
    }

    function removeOperator(address) public onlyOwner {
        _operators[owner] = false;
    }

    function execModule(address module, bytes memory data) public onlyOwnerOrOperators {
        require(_allowed[module], "execModule/not-allowed");
        (bool ok, bytes memory res) = module.delegatecall(data);
        require(ok, string(res));
    }
}

interface WETH9 is ERC20Like {
    function deposit() external payable;
}

contract Setup {
    WETH9 public constant WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint256 public constant WANT = 50 ether;

    Wallet public wallet;

    constructor() payable {
        require(msg.value == WANT);

        address tokenModule = address(new TokenModule());
        // TokenModule tokenModule = new TokenModule();

        wallet = new Wallet();
        wallet.allowModule(tokenModule);

        WETH.deposit{value: msg.value}();
        WETH.approve(address(wallet), type(uint256).max);

        wallet.execModule(
            address(tokenModule), abi.encodeWithSelector(TokenModule.deposit.selector, WETH, address(this), msg.value)
        );
    }

    function isSolved() public view returns (bool) {
        return WETH.balanceOf(address(this)) == WANT;
    }
}
