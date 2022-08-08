PAD contract

PackToken/PackNFT.sol
    Is the first token that PAD will be selling.

PaymentSplitter/PaymentSplitter.sol
    Is the contract to which all the fees are collected and split to the share holders

Shared/SwapStorage.sol
    Is a library of swap metadata, is intended to be extended to add more swap behaviors like timed sells or limiting tokens per address.

Swap/Swap.sol
    Is the Swap contract that connects to PaymentSplitter and is the one that can mint new ERC721 tokens.
    The swap needs to be configured with the PaymentSplitter address.
    Also the token to be minted needs to grant MINTER_ROLE to the Swap contract address to be able to mint.
    New swap pairs can be added from this contract.