# oc_nv.sh
small and simple overclocking script for NVIDIA GPU to replace default script in SimpleMining OS.

## Installation
Connect to you mining rig (directly or via ssh).

Clone repository:

`git clone https://github.com/kusayuzayushko/oc_nv.sh.git`

Backup the default script:

`sudo su` and `mv /root/utils/oc_nv.sh /root/utils/oc_nv.sh.bkp`

Copy new script from ny repo:

`cp oc_nv.sh/oc_nv.sh /root/utils`

Make it executable:

`chmod +x /root/utils/oc_nv.sh`

## Usage

`cd /root/utils && sudo su`

`./oc_nv.sh <CORE OFFSET> <MEM OFFSET> <POWER LIMIT>`

Something like this:

`./oc_nv.sh 50 1000 120` or `./oc_nv.sh 0,50,50 0,1000,1000 100,120,120`

I don't have 1050 cards at the moment, so need someone to test if it's working or not.
Please, report all bugs here or contact cryptoscum in http://chat.simplemining.net/channel/general
