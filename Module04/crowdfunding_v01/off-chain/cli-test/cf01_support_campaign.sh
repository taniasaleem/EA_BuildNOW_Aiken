utxo="e49e71a1f2d3b848113215354712d7d7f4820076a659b271963fb74cd66201ca#1"
script_utxo="abf6de16539ba969e477f8d5a7b89b00866fa585966a3420a0d9d7fb97f3be09#0"
script_address=$(cat ../compiled/crowdf01.addr)
output_campaign="2000000"
output_backer="100000000"
creatorPKH=$(cat $HOME/Dev/Wallets/Adr08.pkh)
backerPKH=$(cat $HOME/Dev/Wallets/Bob.pkh)
collateralPKH=$(cat $HOME/Dev/Wallets/Adr07.pkh)
collateral="4cbf990857530696a12b0062546a4b123ad0bef21c67562e32d03e3288bdcd7b#0"
Adr08=$(cat $HOME/Dev/Wallets/Adr08.addr)

cardano-cli conway transaction build \
  $PREVIEW \
  --tx-in $script_utxo \
  --tx-in-script-file ../compiled/crowdf01.uplc \
  --tx-in-inline-datum-present \
  --tx-in-redeemer-file ../values/cfredeemer_backer.json \
  --tx-in $utxo \
  --required-signer-hash $backerPKH \
  --tx-in-collateral $collateral \
  --tx-out $script_address+$output_campaign \
  --tx-out-inline-datum-file ../values/cfdatum_change1.json \
  --tx-out $script_address+$output_backer \
  --tx-out-inline-datum-file ../values/cfdatum_backer.json \
  --change-address $nami3 \
  --out-file support_campaign.unsigned

cardano-cli conway transaction sign \
    --tx-body-file support_campaign.unsigned \
    --signing-key-file $HOME/Dev/Wallets/Bob.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr08.skey \
    --signing-key-file $HOME/Dev/Wallets/Adr07.skey \
    $PREVIEW \
    --out-file support_campaign.signed

cardano-cli conway transaction submit \
    $PREVIEW \
    --tx-file support_campaign.signed
