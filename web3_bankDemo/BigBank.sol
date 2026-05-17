// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BankDemo.sol";

contract BigBank is BankDemo {
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "deposit must be > 0.001 ether!");
        _;
    }

    function deposit() public payable override(BankDemo) minDeposit {
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender);
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable override(BankDemo) {
        deposit();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "address is invalid");
        owner = newOwner;
    }
}

contract Admin {
    address public adminOwner;

    event AdminWithdraw(address indexed bank, uint256 amount);

    modifier onlyAdminOwner() {
        require(msg.sender == adminOwner, "not adminOwner");
        _;
    }

    constructor() {
        adminOwner = msg.sender;
    }

    function adminWithdraw(IBank bank) external onlyAdminOwner {
        uint256 beforeBalance = address(this).balance;
        bank.withdraw();
        uint256 received = address(this).balance - beforeBalance;
        require(received > 0, "nothing received");

        (bool success, ) = payable(adminOwner).call{value: received}("");
        require(success, "Transfer to adminOwner failed");
        emit AdminWithdraw(address(bank), received);
    }

    receive() external payable {}
}

