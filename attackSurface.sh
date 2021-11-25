#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variable

# extract from nslookup query
nsl=$(nslookup -type=any netflix.com)
nsl4=$(nsl | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++')
# nsl6=$ | still working on this

# extract from host query
hlu=$(host netflix.com) | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++')

# extract IPs from dig query
dlu=$(dig netflix.com any) | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'
# extract hostnames from dig query, resolve with nslookup, and add to surface variable

# combine master variable and dedup
surface="${nsl} ${hlu} ${dlu}"
echo $surface
