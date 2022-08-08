// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
    @title Interface for Pack NFT
    @author Arturo Sosa
    @notice This interface serves for exposing public functions for Web3
 */
interface IPackNFT is IERC721 {
    /**
        @notice Mints and transfer 1 or more NFT to the owner_ address
        @param owner_ Who is going to receive the token
        @param swapId_ ID of the caller doing the minting
        @param amount_ Amount of tokens to mint
        @param isEnabled_ Boolean to check if the caller is enabled or not to mint
        @param issued_ Amount of issued tokens from the caller pool
        @param supply_ Max amount of mintable tokens from the caller pool
        @dev Only an address with MINTER_ROLE role can mint new tokens, this address MUST be a swap contract address
     */
    function mint(address owner_, uint256 swapId_, uint256 amount_, bool isEnabled_, uint256 issued_, uint256 supply_) external;

    /**
        @notice Get the URI assigned to a token
        @param  tokenId_ ID of the token requested
        @return URI of the requested token
     */
    function getTokenURI(uint256 tokenId_)external view returns(string memory);

    /**
        @notice Gets the token of the owner balance using it´s index
        @param owner Owner address
        @param index Index of the token on the owner pool
        @return Token
        @dev If the token index doesn´t exist, it throws
     */
    function getTokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
        @notice Get the token from the emitted pool using it´s index
        @param index Index of the token on the emitted pool
        @return Token
        @dev If the token index doesn´t exist, it throws
     */
    function getTokenByIndex(uint256 index) external view returns (uint256);
    
    /**
        @notice Get´s the total amount of tokens emitted
        @return Total token emitted
     */
    function getTotalSupply() external view returns (uint256);
}