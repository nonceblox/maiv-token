// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Importing OpenZeppelin's EnumerableSet utility for managing address sets.
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title Blacklistable
 * @dev Implements blacklist functionality to enhance security by restricting certain
 * addresses from interacting with the contract.
 * Uses OpenZeppelin's EnumerableSet for efficient address management.
 */
contract Blacklistable {
    error AccountIsBlacklisted(); // Custom error for blacklisted account operations.
    error AccountAlreadyBlacklisted(); // Custom error when trying to blacklist an already blacklisted account.
    error AccountNotBlacklisted(); // Custom error when trying to remove an account that is not blacklisted.

    using EnumerableSet for EnumerableSet.AddressSet; // Extending EnumerableSet utility for AddressSet.
    EnumerableSet.AddressSet private _blacklisted; // Set of addresses that are blacklisted.

    // Events for logging changes to the blacklist.
    event Blacklisted(address indexed account); // Emitted when an address is added to the blacklist.
    event UnBlacklisted(address indexed account); // Emitted when an address is removed from the blacklist.

    /**
     * @notice Modifier to restrict function access to non-blacklisted addresses only.
     * @param account Address to be validated.
     */
    modifier notBlacklisted(address account) {
        // Reverts if the account is blacklisted, preventing further execution.
        if (isBlacklisted(account)) revert AccountIsBlacklisted();
        _; // Continues execution of the function if the account is not blacklisted.
    }

    /**
     * @notice Checks if an address is on the blacklist.
     * @param account Address to check.
     * @return bool True if the address is blacklisted, false otherwise.
     */
    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted.contains(account);
    }

    /**
     * @notice Returns the total number of blacklisted addresses.
     * @return uint256 The number of addresses currently on the blacklist.
     */
    function blacklistedCount() external view returns (uint256) {
        return _blacklisted.length();
    }

    /**
     * @notice Retrieves a blacklisted address by index.
     * @dev Useful for iterating over the entire blacklist when off-chain enumeration is necessary.
     * @param index Index in the blacklist set.
     * @return address The blacklisted address at the specified index.
     */
    function blacklistedAt(uint256 index) external view returns (address) {
        return _blacklisted.at(index);
    }

    /**
     * @dev Internal function to add an address to the blacklist. Emits the Blacklisted event.
     * @param account Address to be added to the blacklist.
     */
    function _addBlacklist(address account) internal {
        // Attempts to add the account to the blacklist set
        // reverts if the account is already blacklisted.
        if (!_blacklisted.add(account)) revert AccountAlreadyBlacklisted();
        emit Blacklisted(account); // Emitting event for transparency and off-chain tracking.
    }

    /**
     * @dev Internal function to remove an address from the blacklist. Emits the UnBlacklisted event.
     * @param account Address to be removed from the blacklist.
     */
    function _removeBlacklist(address account) internal {
        // Attempts to remove the account from the blacklist set
        // reverts if the account is not currently blacklisted.
        if (!_blacklisted.remove(account)) revert AccountNotBlacklisted();
        emit UnBlacklisted(account); // Emitting event for transparency and off-chain tracking.
    }
}
