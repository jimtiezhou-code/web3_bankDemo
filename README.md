# BankDemo - Web3 银行合约

一个基于 Solidity 编写的去中心化银行智能合约，支持 ETH 存款、存款排行追踪及管理员提款。

## 功能

1. **ETH 存款** — 通过 MetaMask 直接向合约转账 ETH 即可自动存款
2. **余额记录** — 合约记录每个地址的累计存款金额
3. **Top 3 排行榜** — 实时追踪存款金额最高的前 3 名地址
4. **管理员提款** — 仅合约部署者（owner）可提取合约内全部 ETH

## 合约接口

| 函数 | 说明 |
|---|---|
| `deposit()` | 向合约存入 ETH（也可直接转账触发 `receive`） |
| `withdraw()` | 管理员提取合约全部余额 |
| `getTotalBalance()` | 查询合约 ETH 总余额 |
| `getDepositorBalance(address)` | 查询指定地址的存款余额 |
| `getTopDepositors()` | 获取 Top 3 存款地址 |
| `getTopDepositAmounts()` | 获取 Top 3 存款金额 |

## 部署与使用

### 1. 编译合约

使用 [Remix IDE](https://remix.ethereum.org/) 或 Hardhat：

```bash
# Hardhat
npm install
npx hardhat compile
```

### 2. 部署

通过 Remix 的 "Deploy & Run Transactions" 面板，选择 `BankDemo` 合约并部署到目标网络。

### 3. 交互

- **存款**：在 MetaMask 中直接向合约地址转账 ETH
- **查询排行**：调用 `getTopDepositors()` 和 `getTopDepositAmounts()`
- **提款**：管理员调用 `withdraw()`

## 技术细节

- Solidity 版本：`^0.8.0`
- 许可证：MIT
- 存款通过 `receive()` 函数自动处理，用户只需向合约转账即可
- 排行榜在每次存款时自动更新，采用插入排序维护降序

---

## BigBank & Admin 合约（Bigbank.sol）

### 概述

`BigBank` 继承自 `BankDemo`，在其基础上增加了：

1. **最低存款限额**：仅允许 `> 0.001 ETH` 的存款（通过 `modifier` 控制）
2. **管理员权限转移**：支持将 `owner` 转移给 `Admin` 合约，实现合约分层管理

`Admin` 合约作为 `BigBank` 的代理管理员，负责代为调用 `withdraw()` 并将资金转给真实管理员（EOA）。

---

### 合约架构

```
用户 (EOA)
  └─→ BigBank.deposit()  [需 > 0.001 ETH]
         └─→ 记录余额 + 更新 Top3

部署者 (EOA)
  ├─ 部署 BigBank
  ├─ 部署 Admin
  ├─ 调用 BigBank.transferOwnership(Admin地址)
  ├─ 调用 Admin.setBigBank(BigBank地址)
  └─ 调用 Admin.adminWithdraw()
         └─→ Admin 合约调用 BigBank.withdraw()
                └─→ ETH 转入 Admin 合约
                       └─→ 再转给 adminOwner (EOA)
```

---

### BankDemo.sol 改动说明

为支持子合约覆写，`BankDemo` 中以下函数新增了 `virtual` 关键字：

```solidity
// 允许子合约覆写 receive()
receive() external payable virtual { ... }

// 允许子合约覆写 deposit()
function deposit() public payable virtual { ... }
```

> **原因**：Solidity 规定，父合约函数必须声明 `virtual` 才能被子合约 `override`，否则编译报错。

---

### BigBank 合约接口

| 函数 / 修改器 | 类型 | 说明 |
|---|---|---|
| `modifier minDeposit()` | modifier | 要求 `msg.value > 0.001 ether`，否则回滚 |
| `deposit()` | `public payable override` | 覆写父合约，叠加 `minDeposit` 限制 |
| `receive()` | `external payable override` | 覆写父合约，确保直接转账也受最低限额约束 |
| `transferOwnership(address)` | `external onlyOwner` | 将 `owner` 转移给 `Admin` 合约地址 |

#### `modifier minDeposit` 设计说明

```solidity
modifier minDeposit() {
    require(msg.value > 0.001 ether, "deposit must be > 0.001 ether!");
    _;  // 通过检查后才执行函数体
}
```

使用 `modifier` 而非在函数体内写 `require` 的原因：
- `deposit()` 和 `receive()` 都需要该限制，`modifier` 避免重复代码
- 职责分离：函数体专注业务逻辑，准入条件交给 modifier

---

### Admin 合约接口

| 函数 / 变量 | 类型 | 说明 |
|---|---|---|
| `adminOwner` | `address public` | Admin 合约的管理员（部署者） |
| `bigBank` | `IBigBank public` | 绑定的 BigBank 合约引用（接口类型） |
| `modifier onlyAdminOwner()` | modifier | 仅 `adminOwner` 可调用 |
| `constructor()` | - | 部署时自动设置 `adminOwner = msg.sender` |
| `setBigBank(address)` | `external onlyAdminOwner` | 绑定目标 BigBank 合约地址 |
| `adminWithdraw()` | `external onlyAdminOwner` | 代调 BigBank.withdraw()，ETH 转给 adminOwner |
| `receive()` | `external payable` | 接收来自 BigBank withdraw 的 ETH |

#### `IBigBank` 接口设计说明

```solidity
interface IBigBank {
    function withdraw() external;
    function transferOwnership(address newOwner) external;
}
```

`Admin` 合约使用接口类型（而非直接引用 `BigBank` 合约类型）的原因：
- **解耦合**：`Admin` 不关心 `BigBank` 的内部实现，只需知道能调用哪些函数
- **灵活性**：未来可替换为其他实现了 `IBigBank` 接口的合约

#### `adminWithdraw()` 资金流转说明

```solidity
function adminWithdraw() external onlyAdminOwner {
    uint256 before = address(this).balance;   // ① 记录调用前余额
    bigBank.withdraw();                        // ② 触发 BigBank 提款 → ETH 到 Admin
    uint256 received = address(this).balance - before; // ③ 计算实收金额
    require(received > 0, "nothing received");
    (bool success, ) = payable(adminOwner).call{value: received}(""); // ④ 转给真人
    require(success, "Transfer to adminOwner failed");
    emit AdminWithdraw(address(bigBank), received); // ⑤ 链上记录
}
```

| 步骤 | 说明 |
|---|---|
| ① | 先快照余额，用于后续计算实收金额 |
| ② | 调用 `BigBank.withdraw()`，因 `owner == Admin合约`，ETH 发到本合约 |
| ③ | 差值计算实收，而非硬编码金额，防止偏差 |
| ④ | 用 `call` 而非 `transfer`，避免 gas 限制导致失败 |
| ⑤ | 发出事件，链上可审计 |

---

### 部署步骤

```
1. 部署 BigBank 合约       → 获得 BigBank 地址
2. 部署 Admin 合约         → 获得 Admin 地址
3. BigBank.transferOwnership(Admin地址)  → 移交管理员权限
4. Admin.setBigBank(BigBank地址)         → 绑定目标合约
5. Admin.adminWithdraw()                 → 提款
```

> ⚠️ 步骤 3 必须在步骤 4 之前执行，否则 `Admin` 无法以 `owner` 身份调用 `BigBank.withdraw()`。

---

### 事件

| 事件 | 触发时机 | 参数 |
|---|---|---|
| `Deposit(address, uint256)` | 每次成功存款 | 存款人地址、存款金额 |
| `Withdraw(address, uint256)` | 管理员提款时 | 管理员地址、提款金额 |
| `AdminWithdraw(address, uint256)` | Admin 代提款时 | BigBank 合约地址、提款金额 |
