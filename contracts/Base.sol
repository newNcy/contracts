// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Authority {
    address owner;
    
    mapping (address => bool) admin;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyAdmin {
        require(owner == msg.sender || admin[msg.sender]);
        _;
    }
    
    constructor () {
        owner = msg.sender;
    } 
    
    function changeOwner(address newOwner) public onlyOwner {
        require (newOwner != owner);
        owner = newOwner;
    }
    
    function setAdmin(address user, bool enable) public onlyOwner {
        admin[user] = enable;
    }
    
    function isAdmin(address user) public view returns (bool) {
        return admin[user];
    }
}

interface Storage {
    function set(address user, uint256 id, uint256 value) external;
    function get(address user, uint256 id) external returns (uint256);
}

