pragma solidity ^0.8.12;

import "./interface/IERC20.sol";
import "./library/SafeERC20.sol";

contract ReentrancyGuard {
    uint256 private _guardValue;

    modifier nonReentrant() {
        require(_guardValue == 0, "REENTRANCY");
        _guardValue = 1;
        _;
        _guardValue = 0;
    }
}

interface IflashLoanCallee {
    function flashLoanCall(address sender, IERC20 token, uint256 amountOut, bytes calldata data) external;
}

contract FlashLoan is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address token;

    constructor(address _token) public {
        token = _token;
    }

    function flashloan(uint256 amountOut, bytes calldata data) public nonReentrant {
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        require(balanceBefore >= amountOut, "Not enough.");
        IERC20(token).safeTransfer(msg.sender, amountOut);
        if (data.length > 0) {
            IflashLoanCallee(msg.sender).flashLoanCall(address(this), IERC20(token), amountOut, data);
        }
        uint256 balanceAfter = IERC20(token).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "FlashLoan Failed.");
    }
}
