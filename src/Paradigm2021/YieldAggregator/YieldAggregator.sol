// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Like {
    function transfer(address dst, uint256 qty) external returns (bool);

    function transferFrom(address src, address dst, uint256 qty) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);
}

interface Protocol {
    function mint(uint256 amount) external;
    function burn(uint256 amount) external;
    function underlying() external view returns (ERC20Like);
    function balanceUnderlying() external view returns (uint256);
    function rate() external view returns (uint256);
}

// accepts multiple tokens and forwards them to banking protocols compliant to an
// interface
contract YieldAggregator {
    address public owner;
    address public harvester;

    mapping(address => uint256) public poolTokens;

    constructor() {
        owner = msg.sender;
    }

    function deposit(Protocol protocol, address[] memory tokens, uint256[] memory amounts) public {
        uint256 balanceBefore = protocol.balanceUnderlying();
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 amount = amounts[i];

            ERC20Like(token).transferFrom(msg.sender, address(this), amount);
            ERC20Like(token).approve(address(protocol), 0);
            ERC20Like(token).approve(address(protocol), amount);
            // reset approval for failed mints
            try protocol.mint(amount) {}
            catch {
                ERC20Like(token).approve(address(protocol), 0);
            }
        }
        uint256 balanceAfter = protocol.balanceUnderlying();
        uint256 diff = balanceAfter - balanceBefore;
        poolTokens[msg.sender] += diff;
    }

    function withdraw(Protocol protocol, address[] memory tokens, uint256[] memory amounts) public {
        uint256 balanceBefore = protocol.balanceUnderlying();
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 amount = amounts[i];
            protocol.burn(amount);
            ERC20Like(token).transfer(msg.sender, amount);
        }
        uint256 balanceAfter = protocol.balanceUnderlying();

        uint256 diff = balanceBefore - balanceAfter;
        poolTokens[msg.sender] -= diff;
    }
}

// dumb bank with 0% interest rates
contract MiniBank is Protocol {
    ERC20Like public override underlying = ERC20Like(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    function mint(uint256 amount) public override {
        require(underlying.transferFrom(msg.sender, address(this), amount));
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
    }

    function burn(uint256 amount) public override {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        require(underlying.transfer(msg.sender, amount));
    }

    function balanceUnderlying() public view override returns (uint256) {
        return underlying.balanceOf(address(this));
    }

    function rate() public view override returns (uint256) {
        return 1;
    }
}

interface WETH9 is ERC20Like {
    function deposit() external payable;
}

contract Setup {
    YieldAggregator public aggregator;
    MiniBank public bank;
    WETH9 constant weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor() payable {
        require(msg.value == 100 ether);
        bank = new MiniBank();

        aggregator = new YieldAggregator();

        weth.deposit{value: msg.value}();
        weth.approve(address(aggregator), type(uint256).max);

        address[] memory _tokens = new address[](1);
        _tokens[0] = address(weth);

        uint256[] memory _amounts = new uint256[](1);
        _amounts[0] = 50 ether;

        // we deposit 50 weth to the system
        aggregator.deposit(Protocol(address(bank)), _tokens, _amounts);
    }

    function isSolved() public view returns (bool) {
        return weth.balanceOf(address(aggregator)) == 0 && weth.balanceOf(address(bank)) == 0;
    }
}
