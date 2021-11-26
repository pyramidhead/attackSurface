#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variable
domain=$1;

# extract exposed hosts from nslookup query
nslh=$(nslookup -type=any $domain) | grep '^Address*'* | grep -v "127.0" | cut -c 10-
# extract nameservers from nslookup query and resolve
nsld=$(nslookup -type=any $domain) | grep 'nameserver' | cut -c 26- | sed -r 's/\.$//'
echo 'nsl output = ';
echo $nsl;

# extract from host query
hlu=$(host $domain) | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])' | awk -v RS="[ \n]+" '!n[$0]++');
echo 'hlu output = ';
echo $hlu;

# extract IPs from dig query
dlu=$(dig $domain any) | egrep -o '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))' | awk -v RS="[ \n]+" '!n[$0]++';
echo $dlu
# extract hostnames from dig query, resolve with nslookup
dho=$(dig $domain any) | egrep -o '^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$';
# | awk to parse for hostnames goes here | resolving hostnames to ips goes here, still working on this
# append output of dho to dlu
echo 'dho output = ';
echo $dhol
dhu="$dlu $dho"l
echo 'dlu output = ';
echo $dlul

# combine into master variable
surface="${nsl} ${hlu} ${dlu}";
# deduplicate rows as we're using a few discovery methods

echo 'final output = ';
echo $surface;
