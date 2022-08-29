// SPDX-License-Identifier: No License
pragma solidity ^0.8.0;

import "../node_modules/openzeppelin-contracts/token/ERC20/IERC20.sol";
import "../node_modules/openzeppelin-contracts/access/Ownable.sol";

contract Wallet is Ownable {

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }
    mapping(bytes32 => Token) public tokenMapping;
    bytes32[] public tokenList;

    mapping(address => mapping(bytes32 => uint256)) public balances;

    modifier tokenExists(bytes32 ticker) {
        require(tokenMapping[ticker].tokenAddress != address(0), "Token does not exist");
        _;
    }

    function addToken(bytes32 ticker, address tokenAddress) external onlyOwner{
        tokenMapping[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint256 amount, bytes32 ticker) external tokenExists(ticker){

        IERC20(tokenMapping[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender][ticker] += amount;
    }

    function withdraw(uint256 amount, bytes32 ticker) external tokenExists(ticker){
        require(balances[msg.sender][ticker] >= amount, "Insufficient balance");
        
        balances[msg.sender][ticker] -= amount;
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender, amount);
    }
}