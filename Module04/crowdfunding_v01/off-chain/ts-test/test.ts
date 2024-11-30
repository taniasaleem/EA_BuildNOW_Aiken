import {Blockfrost,
    Lucid,
    LucidEvolution,
    SpendingValidator,
    generatePrivateKey,
    fromHex,
    Credential,
    credentialToAddress,
    applyDoubleCborEncoding,
    validatorToAddress,
    Constr,
    Data,
    fromText } from "npm:@lucid-evolution/lucid";
//import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";
import bob_signingKey from "/home/cardano/Dev/Wallets/Bob_skey.json" with {type: 'json'};
import adr08_signingKey from "/home/cardano/Dev/Wallets/Adr08_skey.json" with {type: 'json'};
import {networkConfig} from "./settings.ts"
import { Result } from "./types.ts";

const project_path = "/home/cardano/Dev/CREOW/crowdfunding_v01";

console.log("Network: " + networkConfig.network);
console.log("BlockfrostKEY: " + networkConfig.blockfrostAPIkey);
console.log("BlockfrostURL: " + networkConfig.blockfrostAPI);

const lucid = await Lucid(new Blockfrost(networkConfig.blockfrostURL, networkConfig.blockfrostAPIkey), networkConfig.network);

const bobPaymentCredential: Credential = {
type: "Key",
hash: "2070f8488dd696b78a5f23e38d273550e43660526c4b19cba733b488"  //taken from cardano-cli generated verification key hash
};

const bobStakeCredential: Credential = {
type: "Key",
hash: "8662fe85a22159022d71aebcf4342bcafaa6ede0df2e486a4e751e8e" // taken from cardano-cli generated stake verification key hash
};

const bobSigningkey = bob_signingKey.ed25519;
const adr08Signingkey = adr08_signingKey.ed25519;

console.log("bob sk: " + bobSigningkey);
console.log("adr08 sk: " + adr08Signingkey);

lucid.selectWallet.fromPrivateKey(bobSigningkey);
const bobAddress = await lucid.wallet().address();
console.log("Address: " + bobAddress);

//read validator from blueprint json file created with aiken

const validator = await readValidator();

async function readValidator(): Promise<SpendingValidator> {
const validator = JSON.parse(await Deno.readTextFile("/home/cardano/Dev/EA_DIY_Crowdfunding/crowdfunding_v01/plutus.json")).validators[0];
return {
type: "PlutusV3",
script: applyDoubleCborEncoding(validator.compiledCode)
};
}

const campaignsAddress = validatorToAddress(networkConfig.network, validator,bobStakeCredential); //Bob's staking credential

console.log(campaignsAddress);

console.log(fromText("Demo Campaign 8"));