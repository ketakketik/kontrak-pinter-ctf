// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Context.sol";
import "./interface/ISimpleSwapPair.sol";
import "./interface/IERC20.sol";
import "./library/SafeMath.sol";
import "./library/SafeERC20.sol";
import "./Ownable.sol";

contract N1Farm is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many tokens got staked by user.
        uint256 rewardDebt; // Reward debt. See Explanation below.
    }

    struct PoolInfo {
        uint256 lastUpdatedAt; // Last time when FlagToken got distributed.
        uint256 accRewardsPerToken; // Accumulated Flag per share.
    }

    address flagToken;
    address tokenAccept;
    address public simpleSwapPair;

    uint256 public constant WEEK = 7 days;
    uint256 private constant CAL_MULTIPLIER = 1e18;
    uint256 private constant rewardPerSec = 1;
    uint256 private constant target = 172800000000000000000000;
    mapping(address => PoolInfo) public poolInfos;
    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event SendFlag(address user);

    constructor(address _tokenAccept, address _flagToken, address _simpleSwapPair) public {
        flagToken = _flagToken;
        tokenAccept = _tokenAccept;
        simpleSwapPair = _simpleSwapPair;
        poolInfos[_tokenAccept] = PoolInfo(0, 0);
    }

    function isSolved(address user) public {
        require(userInfo[msg.sender].amount > 0, "Haven't deposited.");
        require(IERC20(flagToken).balanceOf(msg.sender) > target, "FlagToken Not enough");
        emit SendFlag(user);
    }

    function getAmountOut(uint256 amountAIn, uint256 reserveA, uint256 reserveB)
        public
        view
        returns (uint256 amountOut)
    {
        uint256 numerator = amountAIn.mul(reserveB);
        uint256 denominator = reserveA.add(amountAIn);
        amountOut = numerator.div(denominator);
    }

    function getUserAmount(address user) public returns (uint256) {
        return userInfo[user].amount;
    }

    function updatePool(address token) public {
        require(token == tokenAccept, "Fake Token.");
        PoolInfo storage pool = poolInfos[token];
        if (block.timestamp <= pool.lastUpdatedAt) return;
        uint256 total = IERC20(token).balanceOf(address(this));
        if (total == 0 || pool.lastUpdatedAt == 0) {
            pool.lastUpdatedAt = block.timestamp;
            return;
        }
        uint256 timePassed = block.timestamp.sub(pool.lastUpdatedAt);
        uint256 rewards = rewardPerSec.mul(timePassed);
        uint256 newReward = rewards.mul(CAL_MULTIPLIER).div(total);
        pool.accRewardsPerToken = pool.accRewardsPerToken.add(newReward);
        pool.lastUpdatedAt = block.timestamp;
    }

    function claimRewards(address token) public {
        require(token == tokenAccept, "Fake Token.");
        UserInfo storage user = userInfo[msg.sender];
        updatePool(token);
        PoolInfo storage pool = poolInfos[token];
        uint256 pending = user.amount.mul(pool.accRewardsPerToken).div(CAL_MULTIPLIER).sub(user.rewardDebt);
        require(pending > 0, "harvest: no reward owed");
        user.rewardDebt = user.amount.mul(pool.accRewardsPerToken).div(CAL_MULTIPLIER);
        IMintToken(flagToken).mint(msg.sender, pending);
        emit Claim(msg.sender, pending);
    }

    function addRewardtoPool(address token, uint256 amount) public onlyOwner {
        require(token == tokenAccept, "Fake Token.");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    function sellSomeForFlag() public {
        uint256 total = IERC20(tokenAccept).balanceOf(address(this)); // success here
        (uint112 reserveA, uint112 reserveB) = ISimpleSwapPair(simpleSwapPair).getReserves();
        uint256 amoutOut = getAmountOut(total, reserveA, reserveB);
        IERC20(tokenAccept).transfer(simpleSwapPair, total);
        ISimpleSwapPair(simpleSwapPair).swap(0, amoutOut, address(this), "");
    }

    function deposit(address token, uint256 _amount) external {
        require(token == tokenAccept, "Fake Token.");
        PoolInfo memory poolInfo = poolInfos[token];
        updatePool(token);
        UserInfo storage user = userInfo[msg.sender];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(poolInfo.accRewardsPerToken).div(1e18).sub(user.rewardDebt);
            if (pending > 0) {
                IMintToken(flagToken).mint(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            IERC20(token).safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(poolInfo.accRewardsPerToken).div(1e18);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(address token, uint256 _amount) external {
        require(token == tokenAccept, "Fake Token.");
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: _amount not good");
        updatePool(token);
        PoolInfo memory poolInfo = poolInfos[token];
        uint256 pending = user.amount.mul(poolInfo.accRewardsPerToken).div(1e18).sub(user.rewardDebt);
        if (pending > 0) {
            IMintToken(flagToken).mint(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            IERC20(token).safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(poolInfo.accRewardsPerToken).div(1e18);
        emit Withdraw(msg.sender, _amount);
    }
}
