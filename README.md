# Valuefy
A collection of three DEFI contracts, namely Staking, Lending Pool, and Vault, which are required as the first step in developing a DEFI protocol.

### Lending Pool Contract

Create a pool contract that accepts deposit from lenders and borrow money to the borrowers

- Lenders can lend any amount of money and earn some interest for it.
- User or borrower can borrow some amount of tokens (limited) , and pay back with interest for some time period.
- Interest is calculated according the interest rate and borrowing time peroid
- Lender can withdraw the amount later with extra interest earning
- Other functions can be called to determine the balance at any point of time , and the rewards earned

### Vault Contract

Sharing of Yield For the no. of shares owned

- user can deposit their money
- Some shares are minted according to the value deposited
- Vault generate some yield by a puropose and the value of share increases
- user can withdraw the amount by burning those share at any point of time .

### Staking Contract

Rewards user for staking their tokens in the contract

- User can withdraw and deposit at an point of time
- Tokens Earned can be withdrawed any time
- Rewards are calculated with reward rate and time period staked for
- The balance and reward earned can be checked at any point of time

### Inspiration
- Sui is a blockchain focused on mainstream adoption, and we are developing DEFI contracts to elevate Sui's mission to the next level of DEFI. We hope to make this the best library for DEFI contracts on the Sui Blockchain.

### The problem we're solving
- The project aims to address the need for DEFI (Decentralized Finance) capabilities on the Sui blockchain platform. DEFI has gained significant popularity in the blockchain space, offering various financial services such as lending, borrowing, staking, and more, without the need for intermediaries.
- The importance of tackling this problem lies in the growing demand for DEFI services and the potential impact it can have on the blockchain ecosystem. DEFI provides financial inclusivity, accessibility, and transparency to individuals worldwide, empowering them to participate in decentralized financial activities.
- By developing a collection of DEFI contracts, including a lending pool, a vault, and staking, the project aims to provide the foundation for a robust DEFI ecosystem on Sui. This not only benefits existing developers and users but also attracts new participants to the Sui network, increasing its adoption and expanding its use cases.

### Technoligies used
- zkLogin
- Move Languag
- React
- Sui Blockchain 


### Future features
- Expansion of Contract Collection: The next step for DEFI Sui would be to continue adding more contracts to the existing collection. This expansion can include additional DEFI protocols such as decentralized exchanges, yield farming, or liquidity mining. By broadening the range of available contracts, DEFI Sui can cater to a wider array of use cases and attract more developers and users to the platform.


### 💻 Local Development

- Clone the repository

- Then move into the frontend folder

```sh
cd frontend
```

- install dependencies using **yarn** or **npm**

```sh
npm install

or

yarn
```

- start the development server
```sh
npm run dev

or

yarn dev
```

- build with production mode
```sh
npm run build

or

yarn build
```
