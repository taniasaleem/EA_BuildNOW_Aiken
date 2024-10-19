utxoin="8687ae9c23ac451c38a8b4532029a350d6b667f7b4948dc820e7cf6c19fb9bf0#0"
address=$(cat ../compiled/savings.addr) 
output="500000000"

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