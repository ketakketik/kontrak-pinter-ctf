// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '../BaseLevel.sol';
import './HelloEthernaut.sol';

contract InstanceFactory is Level {

  function createInstance(address _player) override public payable returns (address) {
    _player;
    return address(new Instance('ethernaut0'));
  }

  function validateInstance(address payable _instance, address _player) override public view returns (bool) {
    _player;
    Instance instance = Instance(_instance);
    return instance.getCleared();
  }
}