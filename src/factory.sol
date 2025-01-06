// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {DataTypes} from "./utils/DataTypes.sol";
import {UserRegistry} from "./UserRegistry.sol";

contract Factory is DataTypes, AccessControl {
    event jobCreated(
        address client, string title, string description, uint256 budget, uint256 deadline, uint256 status
    );

    mapping(address => TrustedJudge) public trustedJudges;
    mapping(uint256 => Job) public jobs;

    uint256 public jobId;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // modifier onlyClient() {
    //     require(profile[msg.sender].isClient == true, "Only clients can call this function");
    //     _;
    // }

    constructor(address defaultAdmin) {
        grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        grantRole(ADMIN_ROLE, msg.sender);
    }

    function createJob(Job memory _job) external /* onlyClient */ {
        jobs[jobId] = _job;
        jobId++;
        emit jobCreated(_job.client, _job.title, _job.description, _job.budget, _job.deadline, _job.status);
    }

    function getJob(uint256 _jobId) external view returns (Job memory) {
        return jobs[_jobId];
    }
}
