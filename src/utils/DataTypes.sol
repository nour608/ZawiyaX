// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface DataTypes {
    enum JobStatus {
        Pending,
        InProgress,
        Completed,
        Cancelled
    }

    struct Profile {
        string name; // unique and immutable
        address walletAddress; // unique and immutable
        uint256 Reputation; // rating out of 5
        uint256 balance;
        uint256 totalEarnings;
        uint256 totalJobsCompleted;
        uint256 totalJobsCancelled;
        bool isFreelancer;
        bool isClient;
        bytes32 ipfsCID; // for storing user's profile picture, skills, description, etc.
    }

    struct TrustedJudge {
        string name;
        address walletAddress;
        uint256 Reputation;
    }

    ///////////////////
    // Job DataTypes //
    ///////////////////

    struct Job {
        address client;
        uint256 budget;
        address token;
        uint256 deadline;
        JobStatus status; // by default, it is Pending
        bytes32 ipfsCID; // for storing job titel, description, requirements, etc.
        address freelancer;
        Proposal[] jobProposals;
        bool FreelancerApprove;
        bool ClientApprove;
    }

    struct Proposal {
        address freelancer;
        bytes32 EncryptedIpfsCID; // for storing the freelancer's proposal
        bool accepted; // false by default
    }
}
