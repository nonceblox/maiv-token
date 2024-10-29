// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Importing the foundation of our MaivToken from the BaseERC20Token contract
import { BaseERC20Token } from "./base/BaseERC20Token.sol";

/**
 * @title MaivToken
 * @notice A comprehensive ERC20 token with extended functionalities such as burnable,
 * capped supply, and pausability. MaivToken encapsulates the spirit of MAIV, offering
 * a blend of robust features for diverse use cases.
 */
contract MaivToken is BaseERC20Token {
    error ZeroAddress(); // Custom Error for when an address is the zero address.

    // decimals is set to 18 by default
    string private constant _NAME = "MAIV";
    string private constant _SYMBOL = "MAIV";
    uint256 private constant _TOTAL_SUPPLY = 10_000_000_000 ether;

    /**
     * @dev Initializes the MaivToken with predefined name, symbol, and total supply.
     * Assigns the initial supply to a specified holder.
     * @param _ownerAddress Address that will be granted the owner role, allowing for
     * administrative actions.
     * @param _initialHolderAddress Address that will initially hold the total supply
     * of tokens. Ensures no tokens are held by the contract itself.
     */
    constructor(
        address _ownerAddress,
        address _initialHolderAddress,
        address[3] memory _adminAddresses
    ) BaseERC20Token(_NAME, _SYMBOL, _TOTAL_SUPPLY, _ownerAddress, _adminAddresses) {
        // Check for zero address to prevent minting tokens to an invalid address
        if (_initialHolderAddress == address(0)) revert ZeroAddress();
        // Minting the entire total supply to the initial holder address,
        // making the tokens immediately available for circulation.
        _mint(_initialHolderAddress, _TOTAL_SUPPLY);
    }

    /**
     * @notice Allows the owner to collect tokens from a specified address.
     * Useful for recovering tokens accidentally sent to a contract.
     * @param _targetAddress Address from which tokens will be collected.
     * @param _amountToCollect Amount of tokens to be transferred from the
     * target address to the owner.
     */
    function collect(address _targetAddress, uint256 _amountToCollect) external onlyOwner {
        _transfer(_targetAddress, _msgSender(), _amountToCollect);
    }

    /**
     * @notice Allows the owner to mint new tokens up to the cap. Adheres to the
     * total supply constraint set during initialization.
     * @param _amountToMint Amount of new tokens to be minted and assigned to the
     * owner's address.
     */
    function mint(uint256 _amountToMint) external onlyOwner {
        _mint(_msgSender(), _amountToMint);
    }
}
