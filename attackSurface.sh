#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variable
domain=$1;

# add more nameservers
/bin/sh -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'
/bin/sh -c 'echo "nameserver 1.1.1.1" >> /etc/resolv.conf'

# save whois queries for humint
whodat1=$(whois -H whois.arin.net "o $domain")
whodat2=$(whois $domain)

# extract exposed hosts from nslookup query
# extract server IP
nslookup -type=any $domain | grep Server | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > ~/git/attackSurface/surface.txt
# extract address subnet
nslookup -type=any $domain | grep Address | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> ~/git/attackSurface/surface.txt
echo 'surface so far='
cat ~/git/attackSurface/surface.txt
# extract nameservers from nslookup query and resolve
nslookup -type=any $domain | grep 'nameserver' >> ~/git/attackSurface/rawName.txt
cat rawName.txt | sed -r 's/\.$//' | awk '{print $4}' rawName.txt > ~/git/attackSurface/stripName.txt
sed 's/.$//' ~/git/attackSurface/stripName.txt > ~/git/attackSurface/strippedName.txt
rm -f ~/git/attackSurface/stripName.txt
echo 'output of strippedName='
cat ~/git/attackSurface/strippedName.txt
# this contains a lot of ips, strip those first

for h in $( cat ~/git/attackSurface/strippedName.txt ); do
    a=$(dig +short $h | head -n1)
    echo -e "$h\t${a:-Did_Not_Resolve}"
done
echo 'surface as of nslookup='
cat ~/git/attackSurface/surface.txt
# have nameservers stripped down to fqdn, resolve them next
# nsld=$(nslookup -type=any $nsldr) | grep '^Address*'* | grep -v "127.0" | cut -c 10-
# nsl=echo "$($nsls $nsla $nslh $nsld)"
# echo 'nsl output ='
# echo $nsl

# dig around for zone transfers
# for i in $ nsldr; do
#  digout=$($digout dig $i $domain axfr)
# done
# for h in $( cat ~/git/attackSurface/strippedName.txt ); do
#    a=$(dig +short $h | head -n1)
#    echo -e "$h\t${a:-Did_Not_Resolve}"
# done
# echo 'dig output ='
# echo $digout

# extract from host query
# hluv4=$(host $domain) | grep "has address" | cut -c 25-
# hluv6=$(host $domain) | grep "has IPv6" | cut -c 30-
# hlumr=$(host $domain) | grep "mail" | sed 's|.* ||' | sed -r 's/\.$//'
# echo 'hluv4 output ='
# echo $hluv4
# echo 'hluv6 output ='
# echo $hluv6
# echo 'hlumr output ='
# echo $hlumr
# hlu=$($hluv4 $hluv6 $hlumr)
# echo 'hlu output ='
# echo $hlu

# combine into master variables
humint-"${whodat1} ${whodat2}"
# ipsurface="${nsl} ${hlu}";
# deduplicate rows as we're using multiple discovery methods

echo 'human intelligence =';
echo $humint

# echo 'ip surface =';
# echo $ipsurface;
