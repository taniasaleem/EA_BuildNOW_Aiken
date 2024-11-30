utxoin="832cf06b2e388a4569bfce92b79c0a506b5f45df76ba3c4cc7e6e7bff6086770#7"
address=$(cat ../compiled/crowdf01.addr)
output="2000000"

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $utxoin \
  --tx-out $address+$output \
  --tx-out-inline-datum-file ../values/cfdatum.json \
  --change-address $nami3 \
  --out-file createCampaign.unsigned

cardano-cli conway transaction sign \
    --tx-body-file createCampaign.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Adr08.skey \
    $PREVIEW \
    --out-file createCampaign.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file createCampaign.signed