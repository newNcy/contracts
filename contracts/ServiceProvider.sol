// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {Authority, Storage} from "./Base.sol";

contract ServiceProvider is Authority
{
    uint256 public  id;
    uint256 public  price;
    address private  source;
   
    function setPrice(uint256 newPrice) public onlyAdmin {
        price = newPrice;
    }
    function setId(uint256 newId) public onlyAdmin {
        id = newId;
    }
    
    function setStorage(address newSource) public onlyAdmin {
        source = newSource;
    }
    
    function () public payable returns  (bool) {
        Storage data = Storage(source);
        require (data.get(msg.sender, id) < price, "already buy");
        require (msg.sender.balance >= price, "balance not enough");
        
    }
}