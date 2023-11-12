# Multi-Signature Contracts

## Mnemonic Or Private key
Set your mnemonic in truffle-config file.

## Node key
Set your local node address.

## Generate contracts from templates

```javascript
npm run generate
```

## Test

Generate test contracts from templates:
```javascript
npm run generate-test
```

Run tests:

```javascript
truffle develop
```

```javascript
truffle deploy
```

```javascript
truffle test
```

Run coverage:

```javascript
npm run coverage
```

## Migrate optionally add --reset

Binance testnet:

```javascript 
truffle migrate --network bsc
```

## Deploy optionally add --reset

Mainnets:

Ethereum Mainnet: 

```javascript
truffle deploy --network ethereum
```

Binance Mainnet:

```javascript
truffle deploy --network bsc
```

Testnets:

Binance testnet:

```javascript
truffle deploy --network bscTest
```

## Verify COntract

```javascript
truffle run verify MultiSigWallet --network bscTest
```

## Deployed Contracts (Verified)
https://testnet.bscscan.com/address/0x07f7b64e7bE1Bd0C38d37094aA77B951Cb8765A5#writeContract

---------------------------------------------------------------------------------------------------------
## TRACK EVENTs

```javascript
node trackEvents.js
```
