// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../PackToken/IPackNFT.sol";

/**
    @title Library to store swap metaData
    @author Arturo Sosa
 */
library SwapStorage {
    struct Core {
        IERC20 currencyToken;
        IPackNFT itemToken;

        uint256 fee;
        uint256 supply;
        uint256 issued;

        bool isEnabled;
        bool exists;
        bool isEtherSwap;
    }
}