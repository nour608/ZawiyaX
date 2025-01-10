// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {DataTypes} from "./utils/DataTypes.sol";
import {UserRegistry} from "./UserRegistry.sol";

contract JobImplementation is DataTypes {
    UserRegistry public userRegistry;

    address public client;
    address public freelancer;
    address public arbitrator;
    uint256 public jobId;

    modifier freelancersOnly() {
        require(userRegistry.getProfile(msg.sender).isFreelancer, "Only freelancers can submit proposals");
        _;
    }

    modifier clientAndFreelancerOnly() {
        require(
            msg.sender == client || msg.sender == freelancer, "Only the client or freelancer can perform this action"
        );
        _;
    }

    modifier JobOwnerOnly() {
        require(msg.sender == client, "Only the client can perform this action");
        _;
    }

    constructor(address _userRegistry, address _client, uint256 _jobId) {
        userRegistry = UserRegistry(_userRegistry);
        client = _client;
        jobId = _jobId;
    }

    function submitProposal(Proposals memory proposal) external freelancersOnly {}

    function acceptProposal() external JobOwnerOnly {}

    function approveWork(bool approve) external clientAndFreelancerOnly {}

    function cancelJob() external JobOwnerOnly {}

    function Dispute() external clientAndFreelancerOnly {}

    function rateUser(uint256 rating) external clientAndFreelancerOnly {}
}
