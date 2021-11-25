#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variable
domain=$1

# extract from nslookup query
nsl=$(nslookup -type=any netflix.com)
nsl4=$(nsl | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++')
# nsl6=$(nsl | egrep -o 'regex and awk go here') still working on this
# roll the output of both back into finalized nsl
nsl="$nsl4$nsl6"
echo 'nsl output = '
echo $nsl

# extract from host query
hlu=$(host netflix.com) | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++')
echo 'hlu output = '
echo $hlu

# extract IPs from dig query
dlu=$(dig netflix.com any) | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++'
# extract hostnames from dig query, resolve with nslookup
# dho=$(dig netflix.com any | egrep -o '(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])' | awk to parse for hostnames goes here | resolving hostnames to ips goes here) still working on this
# append output of dho to dlu
echo 'dlu output = '
echo $dlu

# combine into master variable
surface="${nsl} ${hlu} ${dlu}"
# deduplicate rows as we're using a few discovery methods

echo 'final output = '
echo $surface
