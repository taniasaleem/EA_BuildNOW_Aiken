utxo="891b6f43d01ebbf22c14c6b034b5cf8e0df1919dfb4ca3d135580e4cab63585b#1"
script_utxo="8b5ada3bc858c4be38140dbaed811158909a2ee064f47dc2071db4bae5666d05#0"
script_address=$(cat ../compiled/crowdf01.addr)
output="2000000"
creatorPKH=$(cat $HOME/Dev/Wallets/Adr08.pkh)
collateralPKH=$(cat $HOME/Dev/Wallets/Adr07.pkh)
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0"
Adr08=$(cat $HOME/Dev/Wallets/Adr08.addr)

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $script_utxo \
  --tx-in-script-file ../compiled/crowdf01.uplc \
  --tx-in-inline-datum-present \
  --tx-in-redeemer-file ../values/cfredeemer.json \
  --tx-in $utxo \
  --required-signer-hash $creatorPKH \
  --tx-in-collateral $collateral \
  --tx-out $nami3+$output \
  --change-address $nami3 \
  --out-file cancel_campaign.unsigned

cardano-cli conway transaction sign \
    --tx-body-file cancel_campaign.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Bob.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr08.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr07.skey \
    $PREVIEW \
    --out-file cancel_campaign.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file cancel_campaign.signed
