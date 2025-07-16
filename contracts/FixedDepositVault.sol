// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract FixedDepositVault {
    IERC20 public immutable token;
    address public owner;

    struct Deposit {
        uint256 amount;
        uint256 startTime;
        uint256 lockDuration;
        bool autoRenew;
        bool withdrawn;
    }

    mapping(address => Deposit[]) public deposits;

    uint256 public annualInterestRate = 5; // 5% APY
    uint256 public earlyWithdrawalPenalty = 2; // 2%

    event Deposited(address indexed user, uint256 indexed index, uint256 amount, uint256 duration, bool autoRenew);
    event Withdrawn(address indexed user, uint256 indexed index, uint256 amount, bool early);

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit(uint256 _amount, uint256 _lockDurationInDays, bool _autoRenew) external {
        require(_amount > 0, "Invalid amount");
        require(_lockDurationInDays > 0, "Duration required");

        token.transferFrom(msg.sender, address(this), _amount);

        deposits[msg.sender].push(Deposit({
            amount: _amount,
            startTime: block.timestamp,
            lockDuration: _lockDurationInDays * 1 days,
            autoRenew: _autoRenew,
            withdrawn: false
        }));

        emit Deposited(msg.sender, deposits[msg.sender].length - 1, _amount, _lockDurationInDays, _autoRenew);
    }

    function withdraw(uint256 _index) external {
        require(_index < deposits[msg.sender].length, "Invalid index");

        Deposit storage dep = deposits[msg.sender][_index];
        require(!dep.withdrawn, "Already withdrawn");

        uint256 elapsed = block.timestamp - dep.startTime;
        bool early = elapsed < dep.lockDuration;

        uint256 payout = dep.amount;
        if (early) {
            uint256 penalty = (payout * earlyWithdrawalPenalty) / 100;
            payout -= penalty;
        } else {
            uint256 interest = (payout * annualInterestRate * dep.lockDuration) / (365 days * 100);
            payout += interest;
        }

        if (dep.autoRenew && !early) {
            dep.startTime = block.timestamp;
        } else {
            dep.withdrawn = true;
        }

        token.transfer(msg.sender, payout);
        emit Withdrawn(msg.sender, _index, payout, early);
    }

    // Admin functions
    function updateAnnualInterestRate(uint256 _newRate) external onlyOwner {
        annualInterestRate = _newRate;
    }

    function updatePenalty(uint256 _newPenalty) external onlyOwner {
        earlyWithdrawalPenalty = _newPenalty;
    }
}
