// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../BankDemo.sol";
import "../BigBank.sol";

contract BankDemoTest is Test {
    BigBank public bigBank;
    Admin public admin;
    address public adminOwner = address(0x1111);
    address public alice = address(0x2222);
    address public bob = address(0x3333);

    function setUp() public {
        // 1. 部署 BigBank
        bigBank = new BigBank();
        // 2. 部署 Admin
        vm.prank(adminOwner);
        admin = new Admin();
    }

    function testFullFlow() public {
        // 3. 转移 BigBank 管理员给 Admin 合约
        bigBank.transferOwnership(address(admin));
        assertEq(bigBank.owner(), address(admin));

        // 4. 模拟多个用户存款
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        vm.prank(alice);
        bigBank.deposit{value: 1 ether}();
        assertEq(bigBank.balances(alice), 1 ether);

        vm.prank(bob);
        bigBank.deposit{value: 2 ether}();
        assertEq(bigBank.balances(bob), 2 ether);

        // 验证 BigBank 余额
        assertEq(address(bigBank).balance, 3 ether);

        // 5. Admin 的 Owner 调用 adminWithdraw
        uint256 adminOwnerBefore = adminOwner.balance;

        vm.prank(adminOwner);
        admin.adminWithdraw(IBank(address(bigBank)));

        // BigBank 资金已转出
        assertEq(address(bigBank).balance, 0);

        // Admin 合约中间余额为 0（已转给 adminOwner）
        assertEq(address(admin).balance, 0);

        // adminOwner 收到全部资金
        assertEq(adminOwner.balance, adminOwnerBefore + 3 ether);
    }

    function testRevertDepositTooSmall() public {
        vm.deal(alice, 1 ether);

        vm.prank(alice);
        vm.expectRevert("deposit must be > 0.001 ether!");
        bigBank.deposit{value: 0.0001 ether}();
    }

    function testRevertWithdrawNotOwner() public {
        vm.deal(alice, 1 ether);

        vm.prank(alice);
        bigBank.deposit{value: 1 ether}();

        // alice 不是 owner，不能提款
        vm.prank(alice);
        vm.expectRevert("Not owner");
        bigBank.withdraw();
    }

    function testRevertAdminWithdrawNotAdminOwner() public {
        bigBank.transferOwnership(address(admin));

        // bob 不是 adminOwner
        vm.prank(bob);
        vm.expectRevert("not adminOwner");
        admin.adminWithdraw(IBank(address(bigBank)));
    }
}
