# 🏦 Fixed Deposit Vault Smart Contract

A decentralized **Fixed Deposit (FD) Vault** that allows users to lock ERC-20 tokens for a fixed period, earn interest, and optionally auto-renew their deposits.

---

## 🔍 What It Does

This smart contract enables users to:

- 💰 **Deposit tokens** for a chosen duration (in days)
- 💸 **Earn interest** (calculated annually) after the lock period ends
- 🚫 **Withdraw early** (with a penalty)
- 🔁 **Auto-renew** deposit when it matures (no manual re-deposit)

It's a decentralized alternative to traditional bank FDs — but fully transparent and programmable on-chain.

---

## 🛠️ Features

- ✅ Lock any amount of tokens for **N days**
- 📈 **Interest based on APY** and lock duration
- ❌ **Early withdrawal penalty** (default: 2%)
- 🔁 Auto-renew option to extend deposit duration seamlessly
- 🔐 Supports multiple deposits per user
- 🔧 Admin control for updating interest and penalty rate

---

## ⚙️ Configuration

- **Token Address**: Provided at deployment
- **Annual Interest Rate**: 5% (default)
- **Early Withdrawal Penalty**: 2% (default)

You can change these via admin functions if needed.

---

## 🧪 Example Use Case

```solidity
// 1. Alice deposits 1000 tokens for 60 days
deposit(1000 * 1e18, 60, true);

// 2. After 60 days, she earns interest and auto-renews
withdraw(0); // triggers payout + renews

// 3. Bob deposits 500 tokens but withdraws early
deposit(500 * 1e18, 30, false);
withdraw(0); // penalty applies
```

## 📜 License

MIT
