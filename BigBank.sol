// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BankDemo.sol";


// ─────────────────────────────────────────────
//  接口：定义 BigBank 对外暴露给 Admin 的接口
// ─────────────────────────────────────────────
interface IBigBank {
    function withdraw() external;
    function transferOwnership(address newOwner) external;
}



// ─────────────────────────────────────────────
//  BigBank：继承自 BankDemo，存款金额必须 > 0.001 ETH
// ─────────────────────────────────────────────
contract BigBank is BankDemo {
    modifier minDeposit() {
        // Modifier：存款金额必须大于 0.001 ETH
        require(msg.value > 0.001 ether, "deposit must be > 0.001 ether!");
        _;
    }
     // 覆写 deposit()，叠加 minDeposit 限制
    function deposit() public payable override minDeposit {
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender);
        emit Deposit(msg.sender, msg.value);

    }
    // receive() 同样受最低存款限制
    receive() external payable {
        deposit();
    }
     // 转移管理员权限（将 owner 转给 Admin 合约）
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0),"address is invalid");
        owner = newOwner;
    }
}

contract Admin {
    // Admin 合约自身的管理员（部署者）
    address public adminOwner;

    //记录绑定BigBank的地址
    IBigBank public bigBank;

    event AdminWithdraw(address indexed bank,uint256 amoutn);

    modifier onlyAdminOwner() {
        require(msg.sender == adminOwner, "not adminOwner");
        _;
    }

    constructor() {
        adminOwner = msg.sender;
    }

    // 绑定 BigBank 合约（部署后调用一次）
    function setBigBank(address _bigBank) external onlyAdminOwner {
        require(_bigBank !=address(0),"_bigBank is bot invalid");
        bigBank =IBigBank(_bigBank);
    }

    // 以 Admin 合约身份调用 BigBank.withdraw()
    // ETH 会先转入本合约，再转给 adminOwner
    function adminWithdraw() external onlyAdminOwner{
        uint256 before = address(this).balance;
        // 触发 BigBank 的 withdraw，ETH 转至本合约（owner == Admin）
        bigBank.withdraw();
        uint256 received = address(this).balance -before;
        require(received > 0,"nothing received");

        // 将收到的 ETH 转给 adminOwner
        (bool success, ) = payable(adminOwner).call{value: received}("");
        require(success,"Transfer to adminOwner failed");
        emit AdminWithdraw(address(bigBank), received);
    }
    // 允许接收来自 BigBank withdraw 的 ETH
    receive() external payable {}
}

