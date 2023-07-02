# Basic Information 
Here I have created a multisig wallet.

A multi-signature wallet (multisig) is a cryptocurrency wallet that requires more than one person to authorize transactions.

The purpose of multisig wallets is to increase security by requiring multiple parties to agree on transactions before execution. Transactions can be executed only when confirmed by a predefined number of owners.

The wallet owners can
- submit a transaction
- approve and revoke approval of pending transcations
- anyone can execute a transcation after enough owners has approved it.

## Quick start
Clone the repository and install all the packages

``` git clone https://github.com/vrajparikh01/Multisig-Wallet ```

``` npm install ```

## Deployment
To deploy all the contracts , run the following command

``` npx hardhat run scripts/deploy.js ```

