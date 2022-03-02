// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract JDR {
    uint256 totalSupply;

    mapping(address => uint256) balances;
    mapping(address => bool) isBlocked;

    address public owner;

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner!");
        _;
    }

    // emission function
    // not public, only for Central Bank of Jamaica 
    // secured, only for owner
    function mint(uint256 amount) public isOwner{
        // also can be a modifier, see Owner
        totalSupply += amount;
        balances[msg.sender] += amount;

        emit Minted(msg.sender, amount);
    }

    // переслать денег
    function transfer(address receiver, uint256 amount) public {
        if (balances[msg.sender] >= amount) {
            if (isBlocked[msg.sender] == false) {
                balances[msg.sender] -= amount;
                balances[receiver] += amount;
                emit Transfer(msg.sender, receiver, amount);
            }
            else {
                emit TransferFailed(msg.sender, receiver, amount, "Sender is blocked");
            }
        }
        else {
            emit TransferFailed(msg.sender, receiver, amount, "Not enough coins");
        }
    }

    // заблокировать пользователя
    function blockUser(address toBlock) public isOwner {
        isBlocked[toBlock] = true;
        emit UserBlocked(toBlock);
    }

    // разблокировать пользователя
    function unblockUser (address toUnblock) public isOwner {
        isBlocked[toUnblock] = false;
        emit UserUnblocked(toUnblock);
    }

    constructor() {
        owner = msg.sender;
    }

    // отнять деняк за бессовестное поведение
    function chargeFine(address toCharge, uint256 amount) public isOwner {
        if (balances[toCharge] < amount) {
            uint256 factAmount = balances[toCharge];
            balances[toCharge] = 0;
            isBlocked[toCharge] = true;
            emit PenaltyCharged(toCharge, factAmount, true);
        }
        else {
            balances[toCharge] -= amount;
            emit PenaltyCharged(toCharge, amount, false);
        }
    }

    event Minted(address who, uint256 amount);
    event Transfer(address to, address from, uint256 amount);
    event TransferFailed(address to, address from, uint256 amount, string errorMsg);
    event UserBlocked(address blocked);
    event UserUnblocked(address unblocked);
    event PenaltyCharged(address charged, uint256 factAmount, bool isBlocked);
}