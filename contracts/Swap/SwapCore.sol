// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../PackToken/IPackNFT.sol";
import "../Shared/SwapStorage.sol";

/**
    @title Base functionality for a swap
    @author Arturo Sosa
    @notice A contract that handles the state of a swap
    @dev This contract can be extended to fit swap needs
 */
contract SwapCore {
    /** 
        @notice Event that logs when a token fee in a swap is updated
        @param fee The new token fee
    */
    event SetFee(uint256 fee);

    /** 
        @notice Event that logs when new swap has been added
        @param swapData The swap metadata
    */
    event AddSwap(SwapStorage.Core swapData);
    
    /** 
        @notice Event that logs when supply for a token is added to a swap
        @param amount Amount of tokens added to the supply
        @param supply The token supply amount plus the amount of token added
    */
    event AddSupply(uint256 amount, uint256 supply);

    /** 
        @notice Event that logs when a new Swap has been enabled
        @param currencyAddress Token that will be requested for a swap
        @param tokenAddress Token that will be minted for a swap
        @param isEnabled The new status for the swap
    */
    event SwapEnable(address currencyAddress, address tokenAddress, bool isEnabled);

    /** 
        @notice Event that logs when a new Swap has been disabled
        @param currencyAddress Token that will be requested for a swap
        @param tokenAddress Token that will be minted for a swap
        @param isEnabled The new status for the swap
    */
    event SwapDisable(address currencyAddress, address tokenAddress, bool isEnabled);

    /** 
        @notice Creates a new swap pair for ETHER / ERC721
        @param itemToken_ Address of the ERC721 to be paired with ETHER
        @param fee_ Initial fee per unit needed to swap tokens
        @param supply_ Initial supply of ERC721 that will be handled by the swap
        @dev This function sets the last flag for SwapStorage.Core to be true forcing it to be an ETHER swap
    */
    function _addSwap(address itemToken_, uint256 fee_, uint256 supply_) internal returns(SwapStorage.Core memory) {
        IERC20 currencyToken = IERC20(address(this));
        IPackNFT itemToken = IPackNFT(itemToken_);

        SwapStorage.Core memory swap = SwapStorage.Core(currencyToken, itemToken, fee_, supply_, 0, false, true, true);        
        emit AddSwap(swap);

        return swap;
    }
    
    /** 
        @notice Creates a new swap pair for ETHER / ERC721
        @param currencyToken_ Address of the ERC20 token to be paired with the ERC721 token
        @param itemToken_ Address of the ERC721 to be paired with the ERC20 token
        @param fee_ Initial fee per token needed to swap tokens
        @param supply_ Initial supply of ERC721 that will be handled by the swap
        @dev This function sets the last flag for SwapStorage.Core to be false forcing it to be an ERC20 swap
    */
    function _addERC20Swap(address currencyToken_, address itemToken_, uint256 fee_, uint256 supply_) internal returns(SwapStorage.Core memory) {
        IERC20 currencyToken = IERC20(currencyToken_);
        IPackNFT itemToken = IPackNFT(itemToken_);

        SwapStorage.Core memory swap = SwapStorage.Core(currencyToken, itemToken, fee_, supply_, 0, false, true, false);        
        emit AddSwap(swap);

        return swap;
    }

    /** 
        @notice Updates the requested fee per token needed for a swap
        @param coreData Metadata of the swap to be updated
        @param fee_ Fee per token needed to swap
    */
    function _setFee(SwapStorage.Core storage coreData, uint256 fee_) internal {
        require(fee_ > 0, "SwapCore: Must provide a fee");
     
        coreData.fee = fee_;
        emit SetFee(coreData.fee);
    }

    /** 
        @notice Adds ERC721 token supply to the provided swap
        @param coreData Metadata of the swap to be updated
        @param amount_ Amount of tokens to add to the supply
    */
    function _addSupply(SwapStorage.Core storage coreData, uint256 amount_) internal {
        require(amount_ > 0, "SwapCore: Must provide a supply");

        coreData.supply += amount_;
        emit AddSupply(amount_, coreData.supply);
    }

    /** 
        @notice Increases the amount of issued tokens on a swap
        @param coreData Metadata of the swap to be updated
        @param amount_ Amount of issued tokens to increase for a swap
        @dev This function MUST be only called after a token mint has been completed
    */
    function _tokenIssued(SwapStorage.Core storage coreData, uint256 amount_) internal {
        coreData.issued += amount_;
    }

    /** 
        @notice Enables a swap to start operating
        @param coreData Metadata of the swap to be updated
    */
    function _enableSwap(SwapStorage.Core storage coreData) internal {
        require(coreData.isEnabled == false, "SwapCore: Swap is already enabled");
        require(coreData.fee > 0, "SwapCore: Swap fee has not been set");
        require(coreData.supply > 0, "SwapCore: Swap supply has not been set");

        coreData.isEnabled = true;
        emit SwapEnable(address(coreData.currencyToken), address(coreData.itemToken), coreData.isEnabled);
    }
    
    /** 
        @notice Disable a swap from operating
        @param coreData Metadata of the swap to be updated
    */
    function _disableSwap(SwapStorage.Core storage coreData) internal {
        require(coreData.isEnabled == true, "SwapCore: Swap is already disabled");

        coreData.isEnabled = false;
        emit SwapDisable(address(coreData.currencyToken), address(coreData.itemToken), coreData.isEnabled);
    }
}