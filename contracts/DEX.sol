// SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

import "./Wallet.sol";

contract Dex is Wallet {

    enum Side {
        BUY,
        SELL
    }

    struct Order {
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
    }

    mapping(bytes32 => mapping(uint => Order[])) public orderBook;

    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(bytes32 ticker) external {

    }


}