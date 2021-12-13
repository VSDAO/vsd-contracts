# Ω Very Simple DAO Smart Contracts


##  🔧 Setting up Local Development
Required: 
- [Node v14](https://nodejs.org/download/release/latest-v14.x/)  
- [Git](https://git-scm.com/downloads)


Local Setup Steps:
1. git clone git@github.com:VSDAO/vsd-contracts.git 
1. Install dependencies: `npm install` 
    - Installs [Hardhat](https://hardhat.org/getting-started/) & [OpenZepplin](https://docs.openzeppelin.com/contracts/4.x/) dependencies
1. Compile Solidity: `npm run compile`
1. **_TODO_**: How to do local deployments of the contracts.


## 🤨 How it all works
![High Level Contract Interactions](./docs/box-diagram.png)

## Mainnet Contracts & Addresses

|Contract       | Addresss                                                                                                            | Notes   |
|:-------------:|:-------------------------------------------------------------------------------------------------------------------:|-------|
|VSD            |[0x0163bf1aa8E3c1a4bf82BE8577dEa471Fb1DEA74](https://cronos.crypto.org/explorer/address/0x0163bf1aa8E3c1a4bf82BE8577dEa471Fb1DEA74)| Main Token Contract|
|sVSD           |[0x2a4F9d68aEd91AE5D1eAc5B44faB0A19E79B95dd](https://cronos.crypto.org/explorer/address/0x2a4F9d68aEd91AE5D1eAc5B44faB0A19E79B95dd)| Staked Vsd|
|Treasury       |[0x8dc2167cB42735A5E9B70E115A501be0250874bE](https://cronos.crypto.org/explorer/address/0x8dc2167cB42735A5E9B70E115A501be0250874bE)| VSD Treasury holds all the assets        |
|OlympusStaking |[0x55aA897b59fbE2ffCB1864b27A753295c53071dc](https://cronos.crypto.org/explorer/address/0x55aA897b59fbE2ffCB1864b27A753295c53071dc)| Main Staking contract responsible for calling rebases every 5200 blocks|
|StakingHelper  |[0x19A72B15FC37C56afc8a4b19cFC5C63ddAD04A62](https://cronos.crypto.org/explorer/address/0x19A72B15FC37C56afc8a4b19cFC5C63ddAD04A62)| Helper Contract to Stake with 0 warmup |
|Staking Warm Up|[0x4b60313d0e30722F848EA242104fD16538C42BB3](https://cronos.crypto.org/explorer/address/0x4b60313d0e30722F848EA242104fD16538C42BB3)| Instructs the Staking contract when a user can claim sVSD |


**Bonds**
- **_TODO_**: What are the requirements for creating a Bond Contract?
All LP bonds use the Bonding Calculator contract which is used to compute RFV. 

|Contract       | Addresss                                                                                                            | Notes   |
|:-------------:|:-------------------------------------------------------------------------------------------------------------------:|-------|
|Bond Calculator|[0x66eD102d14fA384E73fa68a087B91dC3922ed8A9](https://cronos.crypto.org/explorer/address/0x66eD102d14fA384E73fa68a087B91dC3922ed8A9)| |
|VVS bond|[0x139E963027eeE19D7B1836b4234e604A5f351426](https://cronos.crypto.org/explorer/address/0x139E963027eeE19D7B1836b4234e604A5f351426)| Main bond managing serve mechanics for VSD/VVS|
|VVS/VSD SLP Bond|[0xC14e2C0365D4432D91FCD98c5D1cbba2D04f7d60](https://cronos.crypto.org/explorer/address/0xC14e2C0365D4432D91FCD98c5D1cbba2D04f7d60)| Manages mechhanism for thhe protocol to buy baack its own liquidity from the pair. |

## Allocator Guide

The following is a guide for interacting with the treasury as a reserve allocator.

A reserve allocator is a contract that deploys funds into external strategies, such as Aave, Curve, etc.

Treasury Address: `0x31F8Cc382c9898b273eff4e0b7626a6987C846E8`

**Managing**:
The first step is withdraw funds from the treasury via the "manage" function. "Manage" allows an approved address to withdraw excess reserves from the treasury.

*Note*: This contract must have the "reserve manager" permission, and that withdrawn reserves decrease the treasury's ability to mint new OHM (since backing has been removed).

Pass in the token address and the amount to manage. The token will be sent to the contract calling the function.

```
function manage( address _token, uint _amount ) external;
```

Managing treasury assets should look something like this:
```
treasury.manage( DAI, amountToManage );
```

**Returning**:
The second step is to return funds after the strategy has been closed.
We utilize the `deposit` function to do this. Deposit allows an approved contract to deposit reserve assets into the treasury, and mint OHM against them. In this case however, we will NOT mint any OHM. This will be explained shortly.

*Note* The contract must have the "reserve depositor" permission, and that deposited reserves increase the treasury's ability to mint new OHM (since backing has been added).


Pass in the address sending the funds (most likely the allocator contract), the amount to deposit, and the address of the token. The final parameter, profit, dictates how much OHM to send. send_, the amount of OHM to send, equals the value of amount minus profit.
```
function deposit( address _from, uint _amount, address _token, uint _profit ) external returns ( uint send_ );
```

To ensure no OHM is minted, we first get the value of the asset, and pass that in as profit.
Pass in the token address and amount to get the treasury value.
```
function valueOf( address _token, uint _amount ) public view returns ( uint value_ );
```

All together, returning funds should look something like this:
```
treasury.deposit( address(this), amountToReturn, DAI, treasury.valueOf( DAI, amountToReturn ) );
```
