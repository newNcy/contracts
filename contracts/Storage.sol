// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Authority, Storage} from "./Base.sol";


contract StorageV1 is Authority, Storage {

    mapping (address => mapping(uint256=> uint256)) userStatus;
    
    function set(address user, uint256 id, uint256 value) override public onlyAdmin {
        userStatus[user][id] = value;
    }

    function get(address user, uint256 id) override public view returns (uint256) {
        return userStatus[user][id];
    }
}