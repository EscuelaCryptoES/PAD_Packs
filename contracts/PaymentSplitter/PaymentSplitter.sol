// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

/**
    @title Payment split manager
    @author Arturo Sosa
 */
contract PaymentSplit is PaymentSplitter {
    constructor(address[] memory payees, uint256[] memory shares_)
    PaymentSplitter(payees, shares_) {}
}