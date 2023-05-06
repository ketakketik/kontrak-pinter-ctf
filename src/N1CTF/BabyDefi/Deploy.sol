pragma solidity ^0.8.12;

import "./ERC20.sol";
import "./SimpleSwap.sol";
import "./N1Farm.sol";
import "./FlashLoan.sol";
// import "./Context.sol";

contract Deploy {
    event TOKENA(address);
    event TOKENB(address);
    event POOL(address);
    event N1FARM(address);
    event FLASHLOAN(address);
    // event EXP(address);

    constructor() public {
        // two tokens
        N1Token n1Token = new N1Token();
        FlagToken flagToken = new FlagToken();
        emit TOKENA(address(n1Token));
        emit TOKENB(address(flagToken));
        // init swap pool
        SimpleSwapPair simpleSwap = new SimpleSwapPair(address(n1Token),address(flagToken));
        emit POOL(address(simpleSwap));
        n1Token.mint(address(simpleSwap), 90000000000000000000000);
        flagToken.mint(address(simpleSwap), 90000000000000000000000);
        simpleSwap.mint(address(this));
        // init n1Farm
        N1Farm n1Farm = new N1Farm(address(n1Token),address(flagToken),address(simpleSwap));
        emit N1FARM(address(n1Farm));
        n1Token.mint(address(n1Farm), 6000000000000000000000);
        flagToken.transferOwnership(address(n1Farm));
        // mint to flashloan
        FlashLoan floan = new FlashLoan(address(n1Token));
        emit FLASHLOAN(address(floan));
        n1Token.mint(address(floan), 4000000000000000000000);
        // Exp exp = new Exp(address(n1Token),address(flagToken),address(simpleSwap),address(n1Farm),address(floan));
        // emit EXP(address(exp));
    }

    function isSolved() public view returns (bool) {
        string memory expected = "HelloChainFlag";
        return true;
    }
}
