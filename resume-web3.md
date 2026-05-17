# Solidity Developer — Resume for web3.career

---

## Personal Info

| Field | Detail |
|---|---|
| **Name** | [Your Name / 你的姓名] |
| **Title** | Solidity Developer / Smart Contract Engineer |
| **Location** | [Your City, China] |
| **Email** | [your.email@example.com] |
| **GitHub** | [github.com/your-username] |
| **LinkedIn** | [linkedin.com/in/your-profile] |

> Replace bracketed placeholders `[...]` with your own info.

---

## Professional Summary

Solidity developer with hands-on experience building decentralized finance (DeFi) smart contracts from scratch. Strong understanding of EVM internals, gas optimization, and access control patterns. Previously worked in financial testing, bringing a risk-aware, quality-first mindset to smart contract development. Self-driven learner who systematically studied Web3 "Vibe Coding" and keeps up with the latest Solidity tooling and security best practices.

---

## Core Skills

**Smart Contracts & Blockchain**
- Solidity (^0.8.x), EVM, Ethereum, Hardhat, Remix IDE
- Contract patterns: inheritance, interface segregation, access control (modifiers), proxy architecture
- ERC standards: ERC-20, ERC-721 (familiar)
- Gas optimization, safe ETH transfer patterns (`call` vs `transfer`)
- Events, error handling, custom modifiers

**DeFi Knowledge**
- Decentralized banking/lending protocols
- Staking, deposit tracking, ranking algorithms (on-chain insertion sort)
- Admin proxy / multi-layer contract management

**Dev Tools & Workflow**
- Git, GitHub, Markdown documentation
- MetaMask, Remix, Hardhat
- OpenZeppelin (familiar)

**Soft Skills**
- Financial & risk-aware testing mindset from prior QA career
- Technical documentation writing (English & Chinese)
- Self-directed learning, rapid prototyping (Vibe Coding approach)

---

## Projects

### DeFi Bank Protocol — BigBank & Admin | *Personal Project*

**Stack:** Solidity ^0.8.0, Remix IDE, MetaMask | **Repo:** [github.com/your-username/bank]

Designed and built a modular decentralized banking protocol from scratch, consisting of 3 contracts:

- **BankDemo.sol** — Base contract with ETH deposit, real-time Top-3 depositor leaderboard (on-chain insertion sort), and admin-only withdrawal. All core functions exposed via public getters.
- **BigBank.sol** — Extended BankDemo with a `minDeposit()` modifier requiring `> 0.001 ETH`, and `transferOwnership()` to support contract-based management.
- **Admin.sol** — Proxy admin contract that acts as BigBank's `owner`, enabling delegated withdrawal via `adminWithdraw()`. Uses `IBigBank` interface to decouple from BigBank's internal implementation.

**Highlights:**
- Used `virtual`/`override` to enable safe contract inheritance
- Abstracted contract interaction via interfaces (`IBigBank`) for flexibility and testability
- Implemented safe ETH withdrawal using low-level `call` with return-value checks, avoiding gas-limit pitfalls of `transfer`/`send`
- Wrote comprehensive bilingual README with architecture diagrams, interface tables, and deployment steps

### On-Chain Top-3 Depositor Tracker | *Part of BankDemo*

**Stack:** Solidity ^0.8.0

Implemented a real-time Top-3 depositor leaderboard purely on-chain using an insertion-sort algorithm. The `updateTopDepositors()` function:
- Deduplicates existing entries before re-insertion
- Maintains descending order by balance with O(1) storage (fixed-size `address[3]` array)
- Automatically fires on every deposit without requiring off-chain indexing

---

## Work Experience

### Financial QA / Tester | *[Company Name], [City]* | *[Duration, e.g., 2022–2024]*

- Performed functional, regression, and risk-based testing on financial systems, ensuring data integrity and compliance with business rules.
- Developed test cases for complex financial workflows, including edge cases for numerical precision, boundary conditions, and transaction rollback scenarios.
- Collaborated with developers and product teams to document bugs, track resolution, and validate fixes.
- Cultivated a detail-oriented, security-conscious mindset directly transferable to smart contract auditing and testing.

> Tailor company name and dates to your actual experience.

---

## Education

**Nanchang Institute of Technology (南昌理工学院)** — *[Degree, e.g., Bachelor of Engineering / 本科]*

*[Major, e.g., Computer Science & Technology / 计算机科学与技术]* | *[Graduation Year]*

---

## Languages

- **Chinese (中文)** — Native
- **English** — Technical reading & writing (Solidity docs, whitepapers, README documentation)

---

## Links

- GitHub: [github.com/your-username]
- Portfolio / Demo Repo: [github.com/your-username/bank]
- LinkedIn: [linkedin.com/in/your-profile]

---

## About This Resume

This resume is tailored for **web3.career** and similar Web3 job platforms. When filling out the web3.career profile:

1. **Title** — Set to "Solidity Developer" or "Smart Contract Engineer"
2. **Skills tags** — Add: `Solidity`, `EVM`, `DeFi`, `Smart Contracts`, `Ethereum`, `Hardhat`, `Remix`
3. **Bio** — Copy the `Professional Summary` section above
4. **Experience** — Fill in your financial testing role and any other roles
5. **Projects** — Link your GitHub repo

> **Tip:** Make sure your GitHub repo is public and the README is polished (it already is). Recruiters on web3.career often check GitHub directly — a clean, documented project is a strong signal.
