// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Importing OpenZeppelin contract modules for ERC20 functionalities, burnable, capped, and
// permit extensions, as well as pausable, ownable, and access control features.
// Additionally, import a custom blacklist management utility.
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ERC20Capped } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Blacklistable } from "../../utils/Blacklistable.sol";

/**
 * @title Base ERC20 Token
 * @dev Extends ERC20 standard with additional features: burnable, capped supply, permit, pausability,
 * ownership, access control, and blacklist management.
 * Suitable for a wide range of dApps requiring complex access and permissions management.
 */
abstract contract BaseERC20Token is
    ERC20,
    ERC20Burnable,
    ERC20Capped,
    ERC20Permit,
    Pausable,
    Ownable,
    AccessControl,
    Blacklistable
{
    // Custom error for signaling that an operation cannot proceed because the contract is paused.
    error ContractPaused();
    /// Custom error for signaling that ownership can't be transferred to same address again
    error SelfOwnershipTransfer();

    // Identifier for the role with administrative privileges.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /**
     * @dev Sets up the ERC20 token with a name, symbol, total supply cap, and initial owner.
     * Grants the default admin role to the initial owner, enabling role management.
     * @param name Name of the ERC20 token.
     * @param symbol Symbol of the ERC20 token.
     * @param totalSupply Maximum supply of the token.
     * @param owner Address to be granted initial ownership and default admin role.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address owner,
        address[3] memory adminAddresses
    ) ERC20(name, symbol) ERC20Capped(totalSupply) ERC20Permit(name) Ownable(owner) {
        _transferOwnership(owner);
        _grantRole(ADMIN_ROLE, adminAddresses[0]);
        _grantRole(ADMIN_ROLE, adminAddresses[1]);
        _grantRole(ADMIN_ROLE, adminAddresses[2]);
    }

    /**
     * @notice Pauses all token transfers and sensitive operations. Can only be called by
     * an account with the admin role.
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers and operations, reverting the effect of `pause()`.
     * Can only be called by an account with the admin role.
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Adds multiple accounts to the blacklist, preventing them from participating
     * in token operations. Can only be called by an account with the admin role.
     * @param accounts Array of addresses to be blacklisted.
     */
    function addBlacklists(address[] calldata accounts) external onlyRole(ADMIN_ROLE) {
        for (uint256 i = 0; i < accounts.length; i++) {
            _addBlacklist(accounts[i]);
        }
    }

    /**
     * @notice Removes multiple accounts from the blacklist, allowing them to participate
     * in token operations again. Can only be called by an account with the admin role.
     * @param accounts Array of addresses to be removed from the blacklist.
     */
    function removeBlacklists(address[] calldata accounts) external onlyRole(ADMIN_ROLE) {
        for (uint256 i = 0; i < accounts.length; i++) {
            _removeBlacklist(accounts[i]);
        }
    }

    /**
     * @dev Overrides the `renounceOwnership` function to prevent renouncing ownership,
     * maintaining control over the contract.
     */
    function renounceOwnership() public override {
        super.renounceOwnership();
    }

    /**
     * @dev Overrides the `transferOwnership` function to enable safe transfer of ownership
     * under specific conditions.
     * @param newOwner Address of the new owner.
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        if (newOwner == owner()) revert SelfOwnershipTransfer();
        super.transferOwnership(newOwner);
    }

    /**
     * @dev Extends token transfer and minting checks with additional conditions: contract must
     * not be paused, and none of the involved addresses can be blacklisted.
     * @param from Address tokens are being transferred from.
     * @param to Address tokens are being transferred to.
     * @param amount Number of tokens being transferred or minted.
     */
    function _update(
        address from,
        address to,
        uint256 amount
    )
        internal
        virtual
        override(ERC20, ERC20Capped)
        notBlacklisted(from)
        notBlacklisted(to)
        notBlacklisted(_msgSender())
    {
        // Checks if the contract is paused before proceeding with token-related operations.
        // If the contract is paused, the operation is halted and a `ContractPaused` error is thrown.
        if (paused()) {
            revert ContractPaused();
        }
        super._update(from, to, amount);
    }
}
