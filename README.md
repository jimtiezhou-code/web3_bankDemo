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
