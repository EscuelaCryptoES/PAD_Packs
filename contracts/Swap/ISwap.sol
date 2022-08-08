// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9;

import "../Shared/SwapStorage.sol";

/**
    @title Interface for Swap
    @author Arturo Sosa
    @notice This interface serves for exposing public functions for Web3
 */
interface ISwap {
    /**
        @notice Get the requested swap metadata
        @param swapId_ ID of the requested swap
        @return metadata
     */
    function getSwap(uint256 swapId_) external returns(SwapStorage.Core memory);

    /**
        @notice Verify if the requested swap exists
        @param swapId_ ID of the requested swap
        @return exists
     */
    function exists(uint256 swapId_) external returns(bool);

    /**
        @notice Get the amount of issued tokens for the requested swap
        @param swapId_ ID of the requested swap
        @return issuedAmount
     */
    function getIssued(uint256 swapId_) external returns(uint256);

    /**
        @notice Get the amount of tokens in supply for the requested swap
        @param swapId_ ID of the requested swap
        @return tokenSupply
     */
    function getSupply(uint256 swapId_) external returns(uint256);

    /**
        @notice Verify if a swap is enabled
        @param swapId_ ID of the requested swap
        @return isEnabled
     */
    function isEnabled(uint256 swapId_) external returns(bool);

    /**
        @notice Swap operation from ETHER to ERC721
        @param swapId_ ID of the requested swap
        @param amount_ Amount of tokens to mint
        @dev This operation is payable and the funds will be redirected to the PaymentSplit contract
     */
    function swapTokens(uint256 swapId_, uint256 amount_) external payable;

    /**
        @notice Swap operation from ERC20 to ERC721
        @param swapId_ ID of the requested swap
        @param amount_ Amount of tokens to mint
        @dev This operation is payable and the funds will be redirected to the PaymentSplit contract
     */
    function swapERC20Tokens(uint256 swapId_, uint256 amount_) external;
}