// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {DataTypes} from "./utils/DataTypes.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract UserRegistry is DataTypes, AccessControl, Pausable {
    event ProfileCreated(string name, address walletAddress, bool isFreelancer, bool isClient, string ipfsCID);
    event ProfileUpdated(address walletAddress, string newIpfsCID, uint256 timestamp);
    event ContractPaused(address admin, uint256 timestamp);
    event ContractUnpaused(address admin, uint256 timestamp);

    mapping(address => Profile) public profile;
    mapping(string => bool) private usedNames;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(address defaultAdmin) {
        grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        grantRole(ADMIN_ROLE, msg.sender);
    }

    // Function to create a profile
    function createProfile(
        string memory _name,
        address _walletAddress,
        bool _isFreelancer,
        bool _isClient,
        string memory _ipfsCID
    ) external whenNotPaused {
        require(msg.sender == _walletAddress, "Only the owner can create a profile");
        require(!usedNames[_name], "Name already taken");
        require(profile[_walletAddress].walletAddress == address(0), "Profile already exists");

        // Create the profile
        profile[_walletAddress] = Profile({
            name: _name,
            walletAddress: _walletAddress,
            Reputation: 3.0, // Default reputation
            balance: 0,
            totalEarnings: 0,
            totalJobsCompleted: 0,
            totalJobsCancelled: 0,
            isFreelancer: _isFreelancer,
            isClient: _isClient,
            ipfsCID: _ipfsCID
        });

        // Mark the name as used
        usedNames[_name] = true;

        emit ProfileCreated(_name, _walletAddress, _isFreelancer, _isClient, _ipfsCID);
    }

    // Function to update a profile
    function updateProfile(string memory _newIpfsCID) external whenNotPaused {
        require(profile[msg.sender].walletAddress != address(0), "Profile does not exist");

        // Update the IPFS CID
        profile[msg.sender].ipfsCID = _newIpfsCID;

        emit ProfileUpdated(msg.sender, _newIpfsCID, block.timestamp);
    }

    function getProfile(address _walletAddress) external view returns (Profile memory) {
        return profile[_walletAddress];
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
        emit ContractPaused(msg.sender, block.timestamp);
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
        emit ContractUnpaused(msg.sender, block.timestamp);
    }
}
