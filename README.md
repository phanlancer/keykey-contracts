# Introducing KeyKey, the Vampiric(Liquidity Migration) DEX 🔑🔑

## So What is KeyKey?

### KeyKey = UniSwap V2 + LP Token Staking + Deflationary LP Reward Token

KeyKey is owned and governed by the Community using a **Deflationary Governance Token**.

## 📝 Protocol Design

### 💦 Liquidity Provider Incentives

Of course, one of the natural questions that many may have is: “Why would someone want to provide liquidity to KeyKey, as opposed to Uniswap?”.
With Uniswap, liquidity providers only earn the pool’s trading fees when they are actively providing said liquidity. Once they have withdrawn their portion of the pool, they no longer receive that passive income. Moreover, as protocol gains traction, despite being early liquidity providers, they risk getting their return diluted as (bigger and wealthier) stakeholders such as venture funds, exchanges, mining pools join the protocol with a huge amount of capital.

With KeyKey, one can also provide some liquidity into a pool and earn rewards in the form of LOCK tokens. However, unlike Uniswap, those LOCK tokens will also entitle you to continue to earn a portion of the protocol’s fee, accumulated in LOCK, even if you decide to no longer participate in the liquidity provision. As an early liquidity provider, you become a non-dilutable stakeholder of the protocol.

The earnings that you’ll receive from staking will be proportional to the amount of LP tokens you have staked versus the total amount of LP tokens staked.

And remember, **LOCK is a deflationary token**, so your early support **will not be diluted** by wacky infinite-supply tokenomics! Pre-miners will own approximately **18% of the total LOCK token supply**. After all, there are only so many fish in the sea!

### 👨‍🌾 LOCK Token Distribution

Many of us are existing liquidity providers in Uniswap pools. With that, we have designed the token distribution mechanics to make it as easy as possible for the existing Uniswap liquidity providers to start migrating to our protocol!

To start providing liquidity and earning LOCK tokens, anyone holding Uniswap LP tokens can stake those LP tokens into the corresponding initial list of pools. Once done, they will start earning tokens once rewards starts on block 10780000. The list of eligible LP tokens can be added per on-chain governance. So LP's will decide.

At every block, 27 precious LOCK tokens will be created. These tokens will be equally distributed to the stakers of each of the supported pools.

However, for the first 68000 blocks (~10 days), **the amount of LOCK tokens produced will be 12x**, resulting in 324 LOCK tokens being minted per block. This is to **incentivize early Liquidity Providers and to help streamline The Liquidity Liberation**.

The initial set of available pools:

- CeFi Stablecoins: USDT-ETH, USDC-ETH, DAI-ETH, sUSD-ETH
- Defi Protocols: COMP-ETH, LEND-ETH, BZRX-ETH, FSW-ETH , YFV-USDT, CREAM-ETH,
- Synthetic Assets: SNX-ETH, UMA-ETH
- Oracles: LINK-ETH, BAND-ETH, DIA-ETH
- Zoomernomics: AMPL-ETH, YFI-ETH,YFII-ETH, YAMv2-ETH, eth-RMPL
- Ultra-Tight: (2x reward): LOCK-ETH
  OM-ETH, MTA-ETH, sUSD-$BASED. wNXM-ETH, LRC-ETH, ANT-ETH
  The LOCK/WETH pool gets twice the amount, so be sure to supply your LOCK to Uniswap to become eligible for extra earnings! Once LOCK is live, the community can vote to add more eligible pools, or change the LOCK weight of any pool. Our Liquidity mean Our Rules!

### 💸 Reward Distribution

With the current Uniswap configuration, 0.3% of all trading fees in any pool are proportionately distributed to the pool’s liquidity providers. In KeyKey, 0.25% go directly to the active liquidity providers, while the remaining 0.05% get converted back to LOCK and distributed to the LOCK token holders 📈.
🕑 Protocol Fund
Let’s ensure the long-term viability and sustainability of the project. Following suggestion from the community, 8% of every LOCK distribution is set aside for the development, partnership incentives, & future iterations, including security audits. To bootstrap early development, partnerships, and meme-creation, we have also allocated ~2.27% of the total supply of LOCK for early stage growth.

### ⛵️ The Liquidity Liberation

During the first 68000 blocks from the protocol’s inception (~10 days), we will be migrating all the liquidity tokens staked onto KeyKey contracts. This liberation movement will involve taking all of the Uniswap LP tokens staked on KeyKey, redeeming them on Uniswap for the respective token pairs, and initializing new liquidity pools from those tokens. These new pools will be almost identical to the standard Uniswap pool, with the added feature that any fees accrued will be distributed to LOCK token holders through the logic outlined above.
Once the liberation is complete, the liquidity converted will be fueling the first sets of KeyKey pools, and will bring the protocol into operation immediately. The stakers don’t need to do anything and will continue to receive LOCK token rewards from providing liquidity going forward.

Remember, early Liquidity Providers who stake during the pre-mine will ultimately be rewarded with approximately **18% of the LOCK total Supply**, and **will not be diluted**!

| **$LOCK Tokenomics**        |                                |                  |                   |
| --------------------------- | ------------------------------ | ---------------- | ----------------- |
|                             |                                |                  |                   |
| **LP Pre-Mine**             |                                |                  |                   |
| Starting Block              | 10780000                       |                  |                   |
| Ending Block                | 10848000                       |                  |                   |
| Pre-mine blocks             | 68000                          |                  |                   |
| Pre-mine Reward             | 12X                            |                  |                   |
|                             |                                |                  |                   |
| **Release Model**           |                                |                  |                   |
| Block Reward                | 27                             |                  |                   |
| Halving Period              | 1800000                        |                  |                   |
| Blocks/year (est.)          | 2372500                        |                  |                   |
|                             |                                |                  |                   |
| **Period**                  | **Blocks**                     | **Tokens/Block** | **Tokens/Period** |
| 0 (Premine)                 | 68000                          | 324              | 22032000          |
| 1                           | 1800000                        | 27               | 48600000          |
| 2                           | 1800000                        | 13.5             | 24300000          |
| 3                           | 1800000                        | 6.75             | 12150000          |
| 4                           | 1800000                        | 3.375            | 6075000           |
| 5                           | 1800000                        | 1.6875           | 3037500           |
| 6                           | 1800000                        | 0.84375          | 1518750           |
| 7                           | 1800000                        | 0.421875         | 759375            |
|                             |                                |                  |                   |
| **After 7 Halving Periods** |                                |                  |                   |
|                             | Years →                        |                  | 5.311             |
|                             | Total Supply →                 |                  | 118472625         |
|                             | % of supply held by Preminers→ |                  | 18.597            |

### 🔑 Protocol Integrations

At the protocol and smart contract level, KeyKey shares an identical interface to Uniswap. This means that if your protocol is currently compatible with Uniswap, it should be relatively simple to integrate with KeyKey. We will work with various DeFi and other ecosystem tools to start integrating KeyKey.

### 💻 Smart Contracts

Some codes are from other projects including Uniswap/Yam/Compound/OpenZeppelin and are subjected to their licenses. The followings are the list of the contracts with rough explanation:

- 🔒 [**LockToken**](https://etherscan.io/address/0xB7bB4B08995b96Bb5E577c5B02A237a6c625c172): The token contract, with COMP/YAM voting functionality.
- 🔑 [**KeyMaster**](https://etherscan.io/address/0x0e41986DB14eD784ff959c26D7FD7F2B7375F074): Deposit LPs tokens to farm LOCK.
- 👨‍🔧 **LockSmith**: Collect revenues, convert to LOCK, and send to GateKeeper.
- 💂 **GateKeeper**: Stake LOCK to earn more LOCK
- 📈.👩‍💻 **Migrator**: Migrate MasterChef LP tokens from Uniswap to KeyKey.
- 🏛 **GovernorAlpha** + **Timelock**: Governance from Compound.
- 🦄 **UniswapV2**: UniswapV2 contracts with small modification for Migration.

### Contributing

If you want to contribute to KeyKey and make it better, your help is very welcome.
