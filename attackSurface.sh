#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variable
domain=$1;

# extract exposed hosts from nslookup query
nslh=$(nslookup -type=any $domain) | grep '^Address*'* | grep -v "127.0" | cut -c 10-
# extract nameservers from nslookup query and resolve
nsldr=$(nslookup -type=any $domain) | grep 'nameserver' | cut -c 26- | sed -r 's/\.$//'
nsld=$(nslookup -type=any $nsldr) | grep '^Address*'* | grep -v "127.0" | cut -c 10-
nsl=echo "$($nslh $nsld)"
echo 'nsl output ='
echo $nsl

# extract from host query
hluv4=$(host $domain) | grep "has address" | cut -c 25-
hluv6=$(host $domain) | grep "has IPv6" | cut -c 30-
hlumr=$(host $domain) | grep "mail" | sed 's|.* ||' | sed -r 's/\.$//'
echo 'hluv4 output ='
echo $hluv4
echo 'hluv6 output ='
echo $hluv6
echo 'hlumr output ='
echo $hlumr
hlu=$($hluv4 $hluv6 $hlumr)
echo 'hlu output ='
echo $hlu

# combine into master variable
surface="${nsl} ${hlu}";
# deduplicate rows as we're using two discovery methods

echo 'final output = ';
echo $surface;
