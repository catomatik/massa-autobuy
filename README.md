
## massa-autobuy
MASSA testnet rolls autobuy bash script

![MASSA](https://badgen.net/github/release/massalabs/massa)![BASH](https://badgen.net/badge/language/BASH/black)

![Logo](https://v2.cimg.co/news/85695/216050/main-picture.jpg)

## Installation

Script installation

1. Copy script to massa node home folder
2. Set node password and telegram ids
3. Check massa-client location and change this line to your location
```bash
  cd $HOME/massa/massa-client
```
4. Set cron job
```bash
  crontab -e
  # Paste and save
  * * * * * ~/autobuy.sh
```

