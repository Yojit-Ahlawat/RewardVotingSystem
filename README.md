// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RewardVotingSystem
/// @notice A decentralized voting system that rewards participants with tokens.
/// @dev No imports, constructors, or input fields are used.
contract RewardVotingSystem {
    // --- ERC20-Like Token Logic (Built-in Minimal Token) ---
    string public name = "VoteRewardToken";
    string public symbol = "VRT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "insufficient balance");
        require(allowance[from][msg.sender] >= amount, "allowance too low");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // --- Voting Logic ---
    struct Proposal {
        string description;
        uint256 voteCount;
        bool exists;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    mapping(address => mapping(uint256 => bool)) public hasVoted;

    address public owner;
    bool private initialized;

    uint256 public rewardAmount = 10 * 1e18; // Reward 10 tokens per vote

    event Initialized(address owner);
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(address voter, uint256 proposalId);
    event RewardMinted(address voter, uint256 amount);
    event RewardAmountUpdated(uint256 newAmount);
    event EmergencyWithdraw(address to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier isInitialized() {
        require(initialized, "not initialized");
        _;
    }

    // --- Initialization ---
    function initialize() external {
        require(!initialized, "already initialized");
        owner = msg.sender;
        initialized = true;
        emit Initialized(owner);
    }

    // --- Admin Functions ---
    function createProposal(string calldata description) external onlyOwner isInitialized {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            description: description,
            voteCount: 0,
            exists: true
        });
        emit ProposalCreated(proposalCount, description);
    }

    function updateRewardAmount(uint256 newAmount) external onlyOwner {
        rewardAmount = newAmount;
        emit RewardAmountUpdated(newAmount);
    }

    function emergencyWithdraw(address to, uint256 amount) external onlyOwner {
        require(balanceOf[address(this)] >= amount, "not enough tokens");
        balanceOf[address(this)] -= amount;
        balanceOf[to] += amount;
        emit Transfer(address(this), to, amount);
        emit EmergencyWithdraw(to, amount);
    }

    // --- Voting Function ---
    function vote(uint256 proposalId) external isInitialized {
        require(proposals[proposalId].exists, "proposal does not exist");
        require(!hasVoted[msg.sender][proposalId], "already voted");

        hasVoted[msg.sender][proposalId] = true;
        proposals[proposalId].voteCount++;

        _mint(msg.sender, rewardAmount);

        emit Voted(msg.sender, proposalId);
        emit RewardMinted(msg.sender, rewardAmount);
    }

    // --- Internal Mint Function ---
    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // --- View Functions ---
    function getProposal(uint256 proposalId) external view returns (string memory, uint256, bool) {
        Proposal memory p = proposals[proposalId];
        return (p.description, p.voteCount, p.exists);
    }

    function hasUserVoted(address voter, uint256 proposalId) external view returns (bool) {
        return hasVoted[voter][proposalId];
    }
}
🧾 Summary
✅ Voting system — participants can vote on proposals.
✅ Built-in token — no import; an internal ERC20-like system.
✅ Token rewards — each vote mints tokens for the voter.
✅ Owner-controlled proposals — only the owner can create new proposals.
✅ Simple initialization — one-time initialize() call after deployment.
✅ Emergency withdrawal — owner can move tokens if needed.

Would you like me to generate a README.md file for this contract too (with usage guide and event table)?


2/2







You said:
create read me file for this



2/2

ChatGPT said:
Here’s a professional README.md for your Reward Voting System with Token Rewards contract:

markdown
Copy code
# 🗳️ RewardVotingSystem

A **Solidity-based voting system** where participants earn **token rewards** for voting on proposals.  
This contract is self-contained: **no imports, no constructors, no input fields**.

---

## ⚙️ Features

- ✅ Decentralized voting with multiple proposals
- ✅ Reward participants with ERC20-like tokens
- ✅ Owner-controlled proposal creation
- ✅ Emergency token withdrawal
- ✅ Initialization-only once via `initialize()`
- ✅ View functions for votes and proposals

---

## 🧱 Contract Details

| Property | Value |
|----------|-------|
| Solidity Version | `^0.8.20` |
| Name | `RewardVotingSystem` |
| Token Name | `VoteRewardToken` |
| Token Symbol | `VRT` |
| Decimals | 18 |
| Constructor | None (uses `initialize()`) |
| License | MIT |

---

## 📝 Data Structures

### Proposal
Stores details about a single voting proposal:
```solidity
struct Proposal {
    string description;
    uint256 voteCount;
    bool exists;
}
Mappings
proposals[proposalId] → Stores proposals

hasVoted[user][proposalId] → Tracks if a user voted

balanceOf[address] → Token balances

allowance[owner][spender] → Token allowances

🚀 Key Functions
Initialization
solidity
Copy code
initialize()
Sets the contract owner (call once after deployment)

Admin Functions
solidity
Copy code
createProposal(string calldata description)
updateRewardAmount(uint256 newAmount)
emergencyWithdraw(address to, uint256 amount)
Owner can create new proposals, change reward per vote, and withdraw tokens in emergencies

Voting
solidity
Copy code
vote(uint256 proposalId)
Users vote for a proposal and automatically receive reward tokens

Token Functions
transfer(address to, uint256 amount)

transferFrom(address from, address to, uint256 amount)

approve(address spender, uint256 amount)

Views
getProposal(proposalId) → Returns (description, voteCount, exists)

hasUserVoted(address voter, proposalId) → Checks if user voted

📊 Events
Event	Description
Initialized(address owner)	Triggered once when initialized
ProposalCreated(uint256 proposalId, string description)	New proposal added
Voted(address voter, uint256 proposalId)	User voted
RewardMinted(address voter, uint256 amount)	Tokens minted for voter
RewardAmountUpdated(uint256 newAmount)	Reward per vote changed
EmergencyWithdraw(address to, uint256 amount)	Tokens withdrawn by owner
Transfer(address from, address to, uint256 value)	ERC20 token transfer
Approval(address owner, address spender, uint256 value)	ERC20 token approval

🪜 Workflow
1️⃣ Deploy Contract

No constructor; deploy directly.

2️⃣ Initialize

solidity
Copy code
initialize();
3️⃣ Create Proposals (Owner Only)

solidity
Copy code
createProposal("Proposal Description");
4️⃣ Vote (Users)

solidity
Copy code
vote(proposalId);
User receives reward tokens automatically.

5️⃣ Adjust Reward or Emergency Withdraw (Owner)

solidity
Copy code
updateRewardAmount(20 * 1e18); // Update reward to 20 tokens
emergencyWithdraw(user, 100 * 1e18); // Withdraw tokens if needed

contract address: 0x6bDeBDC91A279C0533f7e76f660dffF454Bf530D
⚠️ Notes
This contract uses a built-in ERC20-like token; no external token imports are needed.

Votes are tracked per user per proposal to prevent multiple votes.

Designed for educational/demo purposes; production deployment requires additional security checks.

🧑‍💻 License
MIT License — Free for personal and commercial use.
