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
        uint filled;
    }

    uint public nextOrderId;

    mapping(bytes32 => mapping(uint => Order[])) public orderBook;

    function getOrderBook(bytes32 ticker, Side side) public view returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public {
        if(side == Side.BUY) {
            require(balances[msg.sender]["ETH"] >= amount * price, "Insufficient ETH Balance");
        } else if(side == Side.SELL) {
            require(balances[msg.sender][ticker] >= amount, "Insufficient ERC20 balance");
        }

        Order[] storage orders = orderBook[ticker][uint(side)];
        orders.push(
            Order(nextOrderId, msg.sender, side, ticker, amount, price, 0)
        );

        // Bubble sort
        uint i = orders.length > 0 ? orders.length - 1 : 0;
        if(side == Side.BUY) {
            for(i; i > 0; i--) {
                if(orders[i - 1].price > orders[i].price) {
                    break;
                }
                Order memory orderToMove = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = orderToMove;
            }
        } else if(side == Side.SELL) {
            for(i; i > 0; i--) {
                if(orders[i - 1].price < orders[i].price) {
                    break;
                }
                Order memory orderToMove = orders[i - 1];
                orders[i - 1] = orders[i];
                orders[i] = orderToMove;
            }
        }

        nextOrderId++;
    }

    function createMarketOrder(Side side, bytes32 ticker, uint amount) public {
        if(side == Side.SELL) {
            require(balances[msg.sender][ticker] >= amount, "Amount exceeds balance");
        }

        uint orderBookSide = side == Side.BUY ? 1 : 0;
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint totalFilled;

        for(uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            uint leftToFill = amount - totalFilled;
            uint availableToFill = orders[i].amount - orders[i].filled;
            uint filled;
            if(availableToFill > leftToFill) {
                filled = leftToFill;
            } else {
                filled = availableToFill;
            }

            orders[i].filled += filled;
            totalFilled += filled;

            uint cost = filled * orders[i].price;

            if(side == Side.BUY) {
                require(balances[msg.sender]["ETH"] >= cost);
                balances[msg.sender]["ETH"] -= cost;
                balances[orders[i].trader][ticker] -= filled;

                balances[orders[i].trader]["ETH"] += cost;
                balances[msg.sender][ticker] += filled;
                
            } else if(side == Side.SELL) {
                balances[msg.sender][ticker] -= filled;
                balances[msg.sender]["ETH"] += cost;

                balances[orders[i].trader][ticker] += filled;
                balances[orders[i].trader]["ETH"] -= cost;
            }
        }

        while(orders.length > 0 && orders[0].filled == orders[0].amount) {
            for(uint256 i = 0; i < orders.length - 1; i++) {
                orders[i] = orders[i + 1];
            }
            orders.pop();
        }
    }

}