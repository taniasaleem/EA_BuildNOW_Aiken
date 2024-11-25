aiken check
aiken build
aiken blueprint convert -m campaign_management_v01 -v manage_campaign.spend >./off-chain/compiled/crowdf01.uplc
aiken address -m campaign_management_v01 -v manage_campaign.spend >./off-chain/compiled/crowdf01.addr