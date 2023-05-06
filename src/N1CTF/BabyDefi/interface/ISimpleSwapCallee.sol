pragma solidity ^0.8;

interface ISimpleSwapCallee {
    function simpleSwapCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
