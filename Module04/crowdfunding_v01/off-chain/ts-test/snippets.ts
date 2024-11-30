//await Deno.writeTextFile("/home/cardano/Dev/Wallets/Adr11.addr", address11);
// Alternative, generate new private keys with Lucid
//  const ourPrivateKey = lucid.utils.generatePrivateKey();
//  await Deno.writeTextFile("OurAddress.skey", ourPrivateKey);
//Cardano Private key in bech32; not the BIP32 private key or any key that is not fully derived. 
// * Only an Enteprise address (without stake credential) is derived.

// const address11 = await lucid
//    .selectWalletFromPrivateKey(test01_signingKey.ed25519)  
//    .credentialToAddress(paymentCredential, stakeCredential)
//    .wallet.address();


