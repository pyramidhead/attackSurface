#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variable
domain=$1;

# save whois queries for humint
whodat1=$(whois -h whois.arin.net "o $domain")
whodat2=$(whois $domain)
echo 'whois output='
echo $whodat1
echo $whodat2

# extract exposed hosts from nslookup query
# extract server IP
nsls=$(nslookup -type=any $domain | grep Server | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
# extract address subnet
nsla=$(nslookup -type=any $domain | grep Address | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
# extract nameservers from nslookup query and resolve
nsldr=$(nslookup -type=any $domain | grep 'nameserver') | cut -c 26- | sed -r 's/\.$//'
nsld=$(nslookup -type=any $nsldr) | grep '^Address*'* | grep -v "127.0" | cut -c 10-
nsl=echo "$($nsls $nsla $nslh $nsld)"
echo 'nsl output ='
echo $nsl

# dig around for zone transfers
for i in $ nsldr; do
  digout=$($digout dig $i $domain axfr)
done
echo 'dig output ='
echo $digout

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

# combine into master variables
humint-"${whodat1} ${whodat2}"
ipsurface="${nsl} ${hlu}";
# deduplicate rows as we're using multiple discovery methods

echo 'human intelligence =';
echo $humint

echo 'ip surface =';
echo $ipsurface;
