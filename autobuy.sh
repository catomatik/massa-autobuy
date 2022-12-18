#!/bin/bash
# Autobuy script for Massa 17.2
# Add to crontab for every minute
# crontab -e
#
# * * * * * path_to_script/autobuy.sh
#
# 2022 (c) catomatik@gmail.com

# Replace with your data
TELEGRAM_BOT_ID="BOT_ID"
TELEGRAM_CHAT_ID="CHAT_ID"
PASSWORD="NODE_PASSWORD"

cd $HOME/massa/massa-client

massa_wallet_address=$(./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.address')
balance=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.final_balance')
[ "$balance" = 'null' ] && balance=0
int_balance=${balance%%.*}
active_rolls=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.active_rolls')
final_rolls=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.final_rolls')
candidate_rolls=$( ./massa-client -p $PASSWORD -j wallet_info | jq -r '.[].address_info.candidate_rolls')

echo Address: $massa_wallet_address
echo Balance: $balance
echo Active rolls: $active_rolls
echo Final rolls: $final_rolls
echo Candidate rolls: $candidate_rolls

if [ $int_balance -ge "100" ]; then
        echo No active rolls! Trying to buy a roll..
        echo $(date) No rolls, trying to buy.. >> $HOME/autobuy.log
        echo $(date) Ballance $balance, Active: $active_rolls, Final: $final_rolls, Candidate: $candidate_rolls >> $HOME/autobuy.log
        let "rolls_to_buy = $int_balance / 100"
        echo "Rolls to buy: $rolls_to_buy"
        ./massa-client -p $PASSWORD buy_rolls $massa_wallet_address $rolls_to_buy 0
        curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_ID/sendMessage?parse_mode=HTML&chat_id=$TELEGRAM_CHAT_ID&text=<b>$HOSTNAME</b>%0ANew massa roll bought: $rolls_to_buy"
fi
