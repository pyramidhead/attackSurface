#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variable

# extract from ifconfig query
# ifc=$(ifconfig -a | egrep -o '([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) | (([a-f0-9:]+:+)+[a-f0-9]+)')
# echo $ifc

# extract from nslookup query
nsl=$(nslookup -type=any netflix.com)
# echo $nsl | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'
# echo $nsl6 | egrep -o ''

# extract from host query
hlu=$(host netflix.com)
# echo $hlu | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'

# extract from dig query
dlu=$(dig netflix.com any)
# echo $dlu | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'

# extract from netdiscover query
nds=$(netdiscover -i <interface> -r <targetSubnet>)
echo $nds | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'

# combine master variable and dedup
surface="${nsl} ${hlu} ${dlu} ${nds}"
echo $surface | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'

# extract from nmap query
nmq=$(nmap -PE -n $surface --top-ports 20)
echo $nmq | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'
