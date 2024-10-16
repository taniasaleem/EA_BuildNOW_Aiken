utxoin="d289035c934945f342d336bcccf55a553783cb22079cbe24d9dd3235bdd71533#0"
address=$(cat ../compiled/savings.addr) 
output="5000000"

cardano-cli conway transaction build \
  --testnet-magic 2 \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-datum-hash-file ../values/saver.json \
  --change-address $(cat ../wallet/alice.addr)  \
  --out-file deposit.unsigned

cardano-cli conway transaction sign \
    --tx-body-file deposit.unsigned \
    --signing-key-file ../wallet/bob/bob.skey \
    --testnet-magic 2 \
    --out-file deposit.signed

cardano-cli conway transaction submit \
    --testnet-magic 2 \
    --tx-file deposit.signed