bob_utxo="ed24c9287d374bd0c88f0a8f3c5388b67734f2d54075756ab38344dc7caad15f#3"
ialice_utxo="2fde867690f62aca23c02393717f0ba4810f30301f9de4ccec1243cb5e361aa3#0"
charlie_addr=$(cat $HOME/Dev/Wallets/Charlie.addr)
amount=1500000000


cardano-cli conway transaction build \
    --tx-in $bob_utxo \
    --tx-in $ialice_utxo \
    --tx-out $charlie_addr+$amount \
    --change-address $nami3 \
    --testnet-magic 2 \
    --out-file multisig.unsigned

cardano-cli conway transaction sign \
    --tx-body-file multisig.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Bob.skey \
    --signing-key-file $HOME/Dev/Wallets/IAlice.skey \
    --testnet-magic 2 \
    --out-file multisig.signed

 cardano-cli conway transaction submit \
    --testnet-magic 2 \
    --tx-file multisig.signed
