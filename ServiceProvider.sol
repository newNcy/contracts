// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Authority} from "./Base.sol";

address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

library ArrayFunctions {
    function checkIdx(uint256 [] storage data, uint256 index) internal view returns (bool) {
        return  0 <= index && index < data.length;
    }
    
    function remove(uint256[] storage data, uint256 index) public {
        if (checkIdx(data, index)) {
            data[index] = data[data.length-1];
            data.pop();
        }
    }
    
    function removeLess(uint256[] storage data, uint256 v) public {
        for (uint256 i = 0; i < data.length; ) {
            if (data[i] < v) {
                remove(data, i);
            } else {
                ++ i;
            }
        }
    }
}

struct Map {
    /* <user, [expiry...]> */
    mapping (address => uint256[]) data;
    /* [user...] */
    address [] keys;
}



library MapFunctions {
    
    function get(Map storage map, address key) public view returns(uint256[] storage) {
        return map.data[key];
    }
    
    function erase(Map storage map,address key) public {
         for (uint256 i = 0; i < map.keys.length; ++i) {
            if (map.keys[i] == key) {
                delete map.data[key];
                map.keys[i] = map.keys[map.keys.length-1];
                map.keys.pop();
            }
        }
    }
    
    function clear(Map storage map)public {
        for (uint256 i = 0; i < map.keys.length; ++i) {
            address key = map.keys[i];
            delete map.data[key];
        }
        delete map.keys;
    }
}


struct Service {
    Map userData;
        
    address priceToken;
    uint256 price;
    uint256 validTime;
}

library ServiceFunctions {
    using MapFunctions for Map;
    using ArrayFunctions for uint256[];
    function reset(Service storage service) public {
        service.userData.clear();
        service.priceToken = ETH;
    }
    
    function addUserOwn(Service storage service, address user, uint256 count) public {
        uint256 time = block.timestamp;
        uint256 [] storage userOwn = service.userData.get(user);
        userOwn.removeLess(time);
       
        while (count --> 0) {
            userOwn.push(time);
        }
    }
    
    
    function getUserOwn(Service storage service, address user) public view  returns (uint256) {
        uint256 [] storage userOwn = service.userData.get(user);
        uint256 count = 0;
        uint256 time = block.timestamp;
        for (uint256 i = 0 ; i < userOwn.length; ++i) {
            if (userOwn[i] > time) {
                count ++;
            }
        }
        return count;
    }
}
    
contract ServiceProvider is Authority {
    
    using ServiceFunctions for Service;
    mapping (uint256 => Service)  serviceData;
    uint256 public rebate;
  
    
    function setServicePrice(uint256 serviceId, uint256 price) public onlyAdmin {
        serviceData[serviceId].price = price;
    }
    
    function setServicePriceToken(uint256 serviceId, address token) public onlyAdmin {
        serviceData[serviceId].priceToken = token;
    }
    
    function setServiceValidTime(uint256 serviceId, uint256 time) public onlyAdmin {
        serviceData[serviceId].validTime = time;
    }
    
   
    function getServicePrice(uint256 serviceId) public view returns (uint256) {
        return serviceData[serviceId].price;
    }
    
    function getServicePriceToken(uint256 serviceId) public view returns (address) {
        return serviceData[serviceId].priceToken;
    }
    
    function getServiceValidTime(uint256 serviceId) public view returns (uint256) {
        return serviceData[serviceId].validTime;
    }
    
    function deleteService(uint256 serviceId) public onlyAdmin {
        serviceData[serviceId].reset();
        delete serviceData[serviceId];
    } 
    
    
    
    function buy(uint serviceId, uint256 count, address invitor) public payable {
        if (isAdmin[msg.sender] || isWhite[msg.sender]) {
            revert("you are free to use it");
        }
        require(msg.value == serviceData[serviceId].price * count, "wrong value");
        //payable(owner).transfer(payable(address(this)).balance);
        //serviceData[serviceId].userPay.set(msg.sender, serviceData[serviceId].price);
    }
    
    function withdraw() public onlyOwner {
        payable(owner).transfer(payable(address(this)).balance);
    }
    
    function userOwn(address user, uint256 serviceId) public view returns (uint256) {
        if (isAdmin[user] || isWhite[user]) {
            return 9999999;
        }
        //return serviceData[serviceId].userPay.get(user)/serviceData[serviceId].price;
    }
    
    receive () external  payable {
    
    }
}