
## massa-autobuy
MASSA testnet rolls autobuy bash script

![MASSA](https://badgen.net/github/release/massalabs/massa)![BASH](https://badgen.net/badge/language/BASH/black)

![Logo](https://pbs.twimg.com/profile_banners/1294959051755925509/1649688288/1500x500)

## Installation

Script installation

1. Copy script to massa node home folder
2. Check massa-client location and change this line to your location
```bash
  cd $HOME/massa/massa-client
```
3. Set cron job
```bash
  crontab -e
  # Paste and save
  # * * * * * ~/autobuy.sh
```    
4. Check activity log at $HOME/autobuy.log
