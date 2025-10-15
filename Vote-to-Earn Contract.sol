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
