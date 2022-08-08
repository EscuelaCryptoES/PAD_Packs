// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ISwap.sol";
import "./SwapCore.sol";
import "../Shared/SwapStorage.sol";

/**
    @title Extended swap contract
    @author Arturo Sosa
    @notice A contract that manages a swap pool and enables to transfer ETHER or ERC20 token to receive an ERC721 token
    @dev This contract relies on SwapCore
 */
contract Swap is ISwap, SwapCore, AccessControlEnumerable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _swapCounter;
    address payable private _paymentAddress;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant TOKEN_ROLE = keccak256("TOKEN_ROLE");

    /** 
        @notice Event that logs the PaymentSplit address change
        @param paymentAddress The new PaymentSplit address
    */
    event SetPaymentAddress(address paymentAddress);
    
    /** 
        @param paymentSplitterAddress The address to direct all the swap fees
        @dev The deployer address get the receives the DEFAULT_ADMIN_ROLE and ADMIN_ROLE
            DEFAULT_ADMIN_ROLE Enables the owner address to grant and revoke roles
            ADMIN_ROLE Enables the address to configure swaps
    */
    constructor(address payable paymentSplitterAddress) {
        _paymentAddress = paymentSplitterAddress;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    mapping(uint256 => SwapStorage.Core) swapMetadata;

    /**
        @notice Get the requested swap metadata from the swap pool
        @param swapId_ ID of the requested swap
        @return metadata
     */
    function _getSwap(uint256 swapId_) private view returns(SwapStorage.Core storage) {
        SwapStorage.Core storage metadata = swapMetadata[swapId_];
        require(metadata.exists == true, "Swap: Nonexistent swap");
        return metadata;
    }
    
    /**
        @notice Update the payment address for the swaps
        @param paymentAdress_ New payment address
        @dev Only ADMIN_ROLE can update the payment address
     */
    function setPaymentAddress(address payable paymentAdress_) external onlyRole(ADMIN_ROLE) {
        _paymentAddress = paymentAdress_;
        emit SetPaymentAddress(_paymentAddress);
    }

    /// @inheritdoc ISwap
    function getSwap(uint256 swapId_) external view returns(SwapStorage.Core memory) {
        return _getSwap(swapId_);
    }

    /// @inheritdoc ISwap
    function exists(uint256 swapId_) external view returns(bool) {
        return _getSwap(swapId_).exists;
    }

    /// @inheritdoc ISwap
    function getIssued(uint256 swapId_) external view returns(uint256) {
        return _getSwap(swapId_).issued;
    }

    /// @inheritdoc ISwap
    function getSupply(uint256 swapId_) external view returns(uint256) {
        return _getSwap(swapId_).supply;
    }
    
    /// @inheritdoc ISwap
    function isEnabled(uint256 swapId_) external view returns(bool) {
        SwapStorage.Core storage core = _getSwap(swapId_);
        return core.isEnabled;
    }

    // See SwapCore.sol
    function _increaseIssuedTokenCount(uint256 swapId_, uint256 amount_) internal {
        SwapStorage.Core storage core = _getSwap(swapId_);
        _tokenIssued(core, amount_);
    }

    // See SwapCore.sol
    function addSwap(address itemToken_, uint256 fee_, uint256 supply_) external onlyRole(ADMIN_ROLE) {
        SwapStorage.Core memory core = _addSwap(itemToken_, fee_, supply_);
        swapMetadata[_swapCounter.current()] = SwapStorage.Core(core.currencyToken, core.itemToken, core.fee, core.supply, core.issued, core.isEnabled, core.isEtherSwap, core.exists);
        _swapCounter.increment();
    }
    
    // See SwapCore.sol
    function addERC20Swap(address currencyToken_, address itemToken_, uint256 fee_, uint256 supply_) external onlyRole(ADMIN_ROLE) {
        SwapStorage.Core memory core = _addERC20Swap(currencyToken_, itemToken_, fee_, supply_);
        swapMetadata[_swapCounter.current()] = SwapStorage.Core(core.currencyToken, core.itemToken, core.fee, core.supply, core.issued, core.isEnabled, core.isEtherSwap, core.exists);
        _swapCounter.increment();
    }

    // See SwapCore.sol
    function setSwapFee(uint256 swapId_, uint256 fee_) external onlyRole(ADMIN_ROLE) {
        SwapStorage.Core storage core = _getSwap(swapId_);
        _setFee(core, fee_);
    }

    // See SwapCore.sol
    function addSupply(uint256 swapId_, uint256 amount_) external onlyRole(ADMIN_ROLE) {
        SwapStorage.Core storage core = _getSwap(swapId_);
        _addSupply(core, amount_);
    }

    // See SwapCore.sol
    function enableSwap(uint256 swapId_) external onlyRole(ADMIN_ROLE) {
        SwapStorage.Core storage core = _getSwap(swapId_);
        _enableSwap(core);
    }

    // See SwapCore.sol
    function disableSwap(uint256 swapId_) external onlyRole(ADMIN_ROLE) {
        SwapStorage.Core storage core = _getSwap(swapId_);
        _disableSwap(core);
    }
    
    /**
        @notice Ensures that the swap data and provided data are correct
        @param core Current swap metadata used for the swap
        @param amount_ Amount of tokens to mint
     */
    function _validateSwap(SwapStorage.Core memory core, uint256 amount_) internal pure {
        require(core.isEnabled == true, "Swap: Swap is not enabled");
        require(amount_ > 0, "Swap: Must provide an amount");
        require((core.issued + amount_) <= core.supply, "Swap: Supply amount exceeded");
    }

    // See SwapCore.sol
    function swapTokens(uint256 swapId_, uint256 amount_) external payable nonReentrant {
        SwapStorage.Core memory core = _getSwap(swapId_);
        require(core.isEtherSwap == true, "Swap: Trying swap ERC20 instead of ETHER");
        _validateSwap(core, amount_);

        uint256 totalFee = core.fee * amount_;
        IPackNFT itemToken = core.itemToken;
        
        require(msg.value >= totalFee, "Swap: Insufficient");
        require(msg.value == totalFee, "Swap: Balance to fee mismatch");
        (bool success, ) = _paymentAddress.call{value: msg.value}("");
        
        require(success == true, "Swap: could not transfer fee");
        itemToken.mint(msg.sender, swapId_, amount_, core.isEnabled, core.issued, core.supply);
        _increaseIssuedTokenCount(swapId_, amount_);
    }
    
    // See SwapCore.sol
    function swapERC20Tokens(uint256 swapId_, uint256 amount_) external nonReentrant {
        SwapStorage.Core memory core = _getSwap(swapId_);
        require(core.isEtherSwap == false, "Swap: Trying swap ETHER instead of ERC20");
        _validateSwap(core, amount_);

        uint256 totalFee = core.fee * amount_;
        IPackNFT itemToken = core.itemToken;
        IERC20 currencyToken = core.currencyToken;

        require(currencyToken.balanceOf(msg.sender) > totalFee, "Swap: Insufficient balance");
        currencyToken.approve(address(this), totalFee);
        SafeERC20.safeTransferFrom(currencyToken, msg.sender, _paymentAddress, totalFee);
        itemToken.mint(msg.sender, swapId_, amount_, core.isEnabled, core.issued, core.supply);
        _increaseIssuedTokenCount(swapId_, amount_);
    }
}