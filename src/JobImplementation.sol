// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {DataTypes} from "./utils/DataTypes.sol";
import {UserRegistry} from "./UserRegistry.sol";
import {ICurrencyManager} from "./interfaces/ICurrencyManager.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract JobImplementation is DataTypes, AccessControl, Pausable {
    using SafeERC20 for IERC20;

    UserRegistry public userRegistry;
    ICurrencyManager public currencyManager;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public jobId;
    mapping(uint256 => Job) public jobs;

    event ProposalSubmitted(uint256 jobId, address freelancer);
    event ContractPaused(address admin, uint256 timestamp);
    event ContractUnpaused(address admin, uint256 timestamp);

    modifier freelancersOnly() {
        require(userRegistry.getProfile(msg.sender).isFreelancer, "Only freelancers can submit proposals");
        _;
    }

    modifier clientOnly() {
        require(userRegistry.getProfile(msg.sender).isFreelancer, "Only the clients can perform this action");
        _;
    }

    modifier clientOrFreelancerOnly(uint256 _jobId) {
        require(
            msg.sender == jobs[_jobId].client || msg.sender == jobs[_jobId].freelancer,
            "Only the client or freelancer can perform this action"
        );
        _;
    }

    modifier JobOwnerOnly(uint256 _jobId) {
        require(msg.sender == jobs[_jobId].client, "Only the client can perform this action");
        _;
    }

    constructor(address _userRegistry, address _currencyManager) {
        currencyManager = ICurrencyManager(_currencyManager);
        userRegistry = UserRegistry(_userRegistry);
        jobId = 1;
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev function to create a job, only clients can create jobs, and the freelancer can be address(0) or
     * an actual address so the clinet can choose an actual freelancer or let the freelancers bid on the job.
     * @param _budget the budget of the job
     * @param _token the token address to be used for the payment
     * @param _deadline the deadline of the job
     * @param _ipfs the ipfs hash of the job description
     * @param _freelancer the address of the freelancer to work on the job
     */
    function createJob(uint256 _budget, address _token, uint256 _deadline, bytes32 _ipfs, address _freelancer)
        external
        clientOnly
    {
        // Checks
        require(userRegistry.getProfile(_freelancer).isFreelancer, "Freelancer does not exist");
        require(_deadline > block.timestamp, "Invalid deadline");
        require(currencyManager.isCurrencyWhitelisted(_token), "Token is not whitelisted");
        // Effects
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _budget);

        // Interactions
        jobs[jobId] = Job({
            client: msg.sender,
            budget: _budget,
            token: _token,
            deadline: _deadline,
            status: JobStatus.Pending,
            ipfsCID: _ipfs,
            freelancer: _freelancer,
            proposals: new Proposals[](0)
        });

        jobId++;
    }

    /**
     * @dev function to submit a proposal for a job, only freelancers can submit proposals
     * @param _jobId the id of the job
     * @param _EncyptedIpfsCID the ipfs hash of the proposal
     * @notice the proposal will be encrypted and stored on the ipfs, the _EncyptedIpfsCID param may be can be string or bytes32 not sure yet
     */
    function submitProposal(uint256 _jobId, bytes32 _EncyptedIpfsCID) external freelancersOnly {
        require(jobs[_jobId].status == JobStatus.Pending, "Job is not pending");
        jobs[_jobId].proposals.push(Proposals({freelancer: msg.sender, EncryptedIpfsCID: _EncyptedIpfsCID}));
        emit ProposalSubmitted(_jobId, msg.sender);
    }

    function acceptProposal(uint256 _jobId) external JobOwnerOnly(_jobId) {}

    function approveWork(bool approve, uint256 _jobId) external clientOrFreelancerOnly(_jobId) {}

    function cancelJob(uint256 _jobId) external JobOwnerOnly(_jobId) {}

    function Dispute(uint256 _jobId) external clientOrFreelancerOnly(_jobId) {}

    function rateUser(uint256 rating, uint256 _jobId) external JobOwnerOnly(_jobId) {}

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
        emit ContractPaused(msg.sender, block.timestamp);
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
        emit ContractUnpaused(msg.sender, block.timestamp);
    }
}
