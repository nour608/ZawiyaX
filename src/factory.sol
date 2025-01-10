// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {DataTypes} from "./utils/DataTypes.sol";
import {UserRegistry} from "./UserRegistry.sol";
import {ICurrencyManager} from "./interfaces/ICurrencyManager.sol";

contract Factory is DataTypes, AccessControl {
    ICurrencyManager public currencyManager;
    UserRegistry public userRegistry;
    address public jobImplementation;

    uint256 public jobId;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(address => TrustedJudge) public trustedJudges;
    mapping(uint256 => Job) public jobs;

    event jobCreated(address client, Job jobData);

    constructor(address _currencyManager, address _jobImplementation, address _userRegistry) {
        currencyManager = ICurrencyManager(_currencyManager);
        userRegistry = UserRegistry(_userRegistry);
        jobImplementation = _jobImplementation;
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(ADMIN_ROLE, msg.sender);
    }

    function createJob(Job memory _job) external {
        jobs[jobId] = _job;
        jobId++;
        emit jobCreated(_job.client, _job);
    }

    function getJob(uint256 _jobId) external view returns (Job memory) {
        return jobs[_jobId];
    }
}
