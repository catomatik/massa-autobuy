#!/bin/bash
# Autobuy script for Massa 19.x
# Add to crontab for every minute
# crontab -e
#
# * * * * * path_to_script/autobuy.sh
#
# 2023 (c) catomatik@gmail.com

# Set telegram ids
TELEGRAM_BOT_ID="BOT_ID"
TELEGRAM_CHAT_ID="CHAT_ID"

# Change to massa password
PASSWORD="NODE_PASSWORD"

# Change it to your massa-client location 
cd $HOME/massa/massa-client

# Alert telegram: allert_telegram "Message"
alert_telegram() {
	curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_ID/sendMessage?parse_mode=HTML&chat_id=$TELEGRAM_CHAT_ID&text=<b>$HOSTNAME</b>%0A$1"
}

# Check error: check_error $id $condition $message
# If eval of $condition is false, then state will be raised
check_error() {
	local id=$1; local condition=$2; local message=$3; local error_file="$HOME/.error.$id"

	if ! eval "$condition"; then
		echo "STATUS: $message"
		if  ! test -f "$error_file"; then
			echo "ERROR: $message"
			touch "$error_file"
			alert_telegram "ERROR: $message"
		fi
		exit
	fi
	if test -f "$error_file"; then
		rm -f "$error_file"
		echo "RECOVERED: $message"
		alert_telegram "RECOVERED $message"
	fi
}

# Check running massa-node
check_error "massa-not-running" "pgrep massa-node &> /dev/null" "Massa: node not runnning"

massa_wallet_info=$(./massa-client -p $PASSWORD -j wallet_info)

massa_wallet_address=$(echo $massa_wallet_info | jq -r '.[].address_info.address' 2> /dev/null)
balance=$(echo $massa_wallet_info | jq -r '.[].address_info.final_balance' 2> /dev/null)
[ "$balance" = 'null' ] && balance=0
int_balance=${balance%%.*}
active_rolls=$(echo $massa_wallet_info | jq -r '.[].address_info.active_rolls' 2> /dev/null)
final_rolls=$(echo $massa_wallet_info | jq -r '.[].address_info.final_rolls' 2> /dev/null)
candidate_rolls=$(echo $massa_wallet_info | jq -r '.[].address_info.candidate_rolls' 2> /dev/null)

# Check wallet info (it is null if node did'nt bootstrap)
check_error "massa-no-wallet-info" "[ $massa_wallet_address != 'null' ]" "Massa: cannot get wallet info, node is'nt bootstrapped or other error"

echo Address: $massa_wallet_address
echo Balance: $balance
echo Active rolls: $active_rolls
echo Final rolls: $final_rolls
echo Candidate rolls: $candidate_rolls

# CHeck wallet ballance and rolls, alert if no rolls and balance to buy
check_error "massa-not-enough-balance" \
	    "[ $int_balance -ge 100 ] || [ $active_rolls -gt 0 ] || [ $final_rolls -gt 0 ] || [ $candidate_rolls -gt 0 ]" \
	    "Massa: no rolls and not enough balance to buy"

if [ $int_balance -gt "99" ]; then
        echo No active rolls! Trying to buy a roll..
        echo $(date) No rolls, trying to buy.. >> $HOME/autobuy.log
        echo $(date) Ballance $balance, Active: $active_rolls, Final: $final_rolls, Candidate: $candidate_rolls >> $HOME/autobuy.log
        let "rolls_to_buy = $int_balance / 100"
        echo "Rolls to buy: $rolls_to_buy"
        ./massa-client -p $PASSWORD buy_rolls $massa_wallet_address $rolls_to_buy 0
	alert_telegram "Massa: new massa roll bought: $rolls_to_buy"
fi
