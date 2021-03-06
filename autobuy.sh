#!/bin/bash
# Autobuy script for Massa 9.2
# Add to crontab for every minute
# crontab -e
#
# * * * * * path_to_script/autobuy.sh
#
# 2022 (c) catomatik@gmail.com

PASSWORD=""

cd $HOME/massa/massa-client

massa_wallet_address=$(./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.address')
balance=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.balance.final_ledger_info.balance')
int_balance=${balance%%.*}
active_rolls=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.rolls.active_rolls')
final_rolls=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.rolls.final_rolls')
candidate_rolls=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.rolls.candidate_rolls')

echo Address: $massa_wallet_address 
echo Balance: $balance
echo Active rolls: $active_rolls
echo Final rolls: $final_rolls
echo Candidate rolls: $candidate_rolls

if [ $int_balance -gt "99" ]  && [ $candidate_rolls -lt "1" ]; then
	echo No active rolls! Trying to buy a roll..
	echo $(date) No rolls, trying to buy.. >> $HOME/autobuy.log
	echo $(date) Ballance $balance, Active: $active_rolls, Final: $final_rolls, Candidate: $candidate_rolls >> $HOME/autobuy.log
	./massa-client buy_rolls $massa_wallet_address 1 0
fi
