// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../Swap/ISwap.sol";
import "./IPackNFT.sol";

/**
    @title Pack NFT
    @author Arturo Sosa
    @notice An NFT token that represents a PAD Pack NFT
 */
contract PackNFT is IPackNFT, ERC721PresetMinterPauserAutoId {
    using Strings for uint256;

    /** 
        @notice Event that logs when the base URI has been updated
        @param baseURI The new base URI for the token
    */
    event UpdateBaseURI(string baseURI);

    /** 
        @notice Event that logs when a new token has been minted
        @param owner The owner of the new token
        @param tokenId The id of the new token
        @param tokenURI The URI generated for the token
    */
    event Minted(address owner, uint256 tokenId, string tokenURI);
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    string private baseURI;

    mapping(uint256 => string) private _tokenURIs;

    /** 
        @notice Initialize the token with name, symbol and base URI
        @param name_ The token name
        @param symbol_ The token symbol
        @param baseURI_ The token base URI
        @dev The deployer address get the receives the DEFAULT_ADMIN_ROLE and ADMIN_ROLE
            DEFAULT_ADMIN_ROLE Enables the owner address to grant and revoke roles, this is granted by ERC721PresetMinterPauserAutoId
            ADMIN_ROLE Enables the address to configure the token
    */
    constructor(string memory name_, string memory symbol_, string memory baseURI_)
    ERC721PresetMinterPauserAutoId(name_, symbol_, baseURI_) {
        baseURI = baseURI_;
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    /** 
        @notice Change the base token URI
        @param baseURI_ The new token base URI
        @dev Only ADMIN_ROLE assigned address can call this function
    */
    function setBaseURI(string memory baseURI_) external onlyRole(ADMIN_ROLE) {
        require(bytes(baseURI_).length > 0, "Token: Must provide and URI");
        baseURI = baseURI_;

        emit UpdateBaseURI(baseURI_);
    }

    /** 
        @notice Return the base URI configured for the token
        @return baseURI
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /** 
        @notice Change the URI the token
        @param tokenId_ ID of the token
        @param tokenURI_ ID of the token
    */
    function _setTokenURI(uint256 tokenId_, string memory tokenURI_) internal virtual {
        require(_exists(tokenId_), "Token: Nonexistent token");
        _tokenURIs[tokenId_] = tokenURI_;
    }

    /// @inheritdoc IPackNFT
    function mint(address owner_, uint256 swapId_, uint256 amount_, bool isEnabled_, uint256 issued_, uint256 supply_) external virtual override onlyRole(MINTER_ROLE) {
        require(amount_ > 0, "Token: Provide an amount");
        require(isEnabled_ == true, "Token: Swap is not enabled");
        require((issued_ + amount_) <= supply_, "Token: Supply amount exceeded");

        for (uint256 idx = 0; idx < amount_; idx++) {
            mint(owner_);

            uint256 tokenId = tokenOfOwnerByIndex(owner_, balanceOf(owner_) -1);
            string memory URI = string(abi.encodePacked("/token/", Strings.toString(tokenId), "/type/", Strings.toString(swapId_)));
            
            _setTokenURI(tokenId, URI);
            emit Minted(owner_, tokenId, URI);
        }
    }

    /// @inheritdoc IPackNFT
    function getTokenURI(uint256 tokenId_) external view returns(string memory) {
        require(_exists(tokenId_), "Token: Nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId_];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId_);
    }

    /// @inheritdoc IPackNFT
    function getTokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        return tokenOfOwnerByIndex(owner, index);
    }

    /// @inheritdoc IPackNFT
    function getTokenByIndex(uint256 index) external view returns (uint256) {
        return tokenByIndex(index);
    }

    /// @inheritdoc IPackNFT
    function getTotalSupply() external view returns (uint256){
        return totalSupply();
    }
}