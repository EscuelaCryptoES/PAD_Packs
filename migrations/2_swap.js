const PaymentSplitter = artifacts.require('PaymentSplitter');
const Swap = artifacts.require('Swap');
const PackNFT = artifacts.require('PackNFT');
const Units = require('ethereumjs-units');

module.exports = async (deployer, network, accounts) => {
  const payees = [accounts[8], accounts[9]];
  const shares = [1, 1];
  const tokenName = 'PAD Pack';
  const tokenSymbol = 'PADP';
  const tokenBaseURI = 'https://padtcg.com/';
  const swapData = {
    silver: { fee: Units.convert(0.035, 'eth', 'wei'), amount: 50000 },
    gold: { fee: Units.convert(0.2, 'eth', 'wei'), amount: 32000 },
  };

  await deployer.deploy(PaymentSplitter, payees, shares);
  const paymentSplitterInstance = await PaymentSplitter.deployed();

  await deployer.deploy(Swap, paymentSplitterInstance.address);
  const swapInstance = await Swap.deployed();

  await deployer.deploy(PackNFT, tokenName, tokenSymbol, tokenBaseURI);
  const erc721Instance = await PackNFT.deployed();

  console.log('Configuring contracts');
  console.log('---------------------');

  const minterRole = await erc721Instance.MINTER_ROLE();
  await erc721Instance.grantRole(minterRole, swapInstance.address);
  await swapInstance.addSwap(erc721Instance.address, swapData.silver.fee, swapData.silver.amount);
  await swapInstance.addSwap(erc721Instance.address, swapData.gold.fee, swapData.gold.amount);
};
