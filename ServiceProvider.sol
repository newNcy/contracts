// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Authority} from "./Base.sol";

struct CleanableMap {
    mapping (address => uint256) data;
    address [] keys;
}

library MapOp {
    function set(CleanableMap storage data,  address key, uint256 value) public {
        bool found = false;
        for (uint i = 0; i < data.keys.length; ++i) {
            if (data.keys[i] == key) {
                found = true;
                break;
            }
        }
        
        if (!found) {
            data.keys.push(key);
        }
        data.data[key] = value;
    }
    
    function get(CleanableMap storage data,address key) public view returns(uint256) {
        return data.data[key];
    }
    
    function erase(CleanableMap storage data,address key) public{
        bool found = false;
         for (uint256 i = 0; i < data.keys.length; ++i) {
            if (data.keys[i] == key) {
                found = true;
            }
            if (found && i != data.keys.length-1) {
                data.keys[i] = data.keys[i+1];
            }
        }
        if (found) {
            data.keys.pop();
        }
    }
    
    function clear(CleanableMap storage data)public {
        for (uint256 i = 0; i < data.keys.length; ++i) {
            data.data[data.keys[i]] = 0;
        }
        delete data.keys;
    }
}


contract ServiceProvider is Authority {
    struct Service {
        CleanableMap userPay;
        uint256 price;
    }
    using MapOp for CleanableMap;
    
    mapping (uint256 => Service)  serviceData;
    address public priceToken;
    
    function setServicePrice(uint256 serviceId, uint256 price) public onlyAdmin {
        serviceData[serviceId].price = price;
    }
    
    function setPriceToken(address token) public onlyAdmin {
        priceToken = token;
    }
    
    function deleteService(uint256 serviceId) public onlyAdmin {
        serviceData[serviceId].userPay.clear();
        delete serviceData[serviceId];
    }
    
    function getServiceUserPay(uint256 serviceId, address user) public view returns (uint256) {
        return serviceData[serviceId].userPay.get(user);
    }
    
    function setServiceUserPay(uint256 serviceId, address user, uint256 value) public onlyAdmin {
        serviceData[serviceId].userPay.set(user, value);
    }
    
    function getServicePrice(uint256 serviceId) public view returns (uint256) {
        return serviceData[serviceId].price;
    }
    
    
    
    function buy(uint serviceId) public payable {
        if (isAdmin[msg.sender]) {
            revert();
        }
        require(msg.value == serviceData[serviceId].price, "wrong value");
        payable(owner).transfer(payable(address(this)).balance);
        serviceData[serviceId].userPay.set(msg.sender, serviceData[serviceId].price);
    }
    
    function withdraw() public onlyOwner {
        payable(owner).transfer(payable(address(this)).balance);
    }
    
    function canUse(address user, uint256 serviceId) public view returns (bool) {
        if (isAdmin[user]) {
            return true;
        }
        return serviceData[serviceId].userPay.get(user) >= serviceData[serviceId].price;
    }
    
    receive () external  payable {
    
    }
}