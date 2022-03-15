#!/bin/bash
# given a domain, define an attack surface of externally accessible hosts

# accept domain variables
domain=$1;

# add more nameservers
echo '; generated by /usr/sbin/dhclient-script
search us-east-2.compute.internal
options timeout:2 attempts:5
nameserver 172.31.0.2
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1' | sudo dd of=/etc/resolv.conf

# save whois queries for humint
whodat1=$(whois -H whois.arin.net "o $domain")
whodat2=$(whois $domain)

# extract server IP
nslookup -type=any $domain | grep Server | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' > ~/git/attackSurface/surface.txt
# extract address subnet
nslookup -type=any $domain | grep Address | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> ~/git/attackSurface/surface.txt
echo 'surface after nslookup='
cat ~/git/attackSurface/surface.txt
# extract nameservers from nslookup query and resolve
nslookup -type=any $domain | grep 'nameserver' >> ~/git/attackSurface/rawName.txt
cat rawName.txt | sed -r 's/\.$//' | awk '{print $4}' rawName.txt > ~/git/attackSurface/stripName.txt
sed 's/.$//' ~/git/attackSurface/stripName.txt > ~/git/attackSurface/nudeName.txt
rm -f ~/git/attackSurface/rawName.txt
rm -f ~/git/attackSurface/stripName.txt
chmod 755 nudeName.txt
while read -r line; do nslookup; done < /home/ec2-user/git/attackSurface/nudeName.txt | grep Address | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' >> /home/ec2-user/git/attackSurface/surface.txt
rm -f nudeName.txt
echo 'adding more nameservers='
cat ~/git/attackSurface/surface.txt

# dig around for zone transfers
dig $domain ANY +nostat +nocmd +nocomments > ~/git/attackSurface/digOut.txt
echo 'dig output='
cat ~/git/attackSurface/digOut.txt
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' digOut.txt >> /home/ec2-user/git/attackSurface/surface.txt
echo 'dig output added='
cat ~/git/attackSurface/surface.txt
# resolve hostnames and extract (remember to throw away $domain)
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
# humint="${whodat1} ${whodat2}"
# ipsurface="${nsl} ${hlu}";
# deduplicate rows as we're using multiple discovery methods

# echo 'human intelligence =';
# echo $humint

# echo 'ip surface =';
# echo $ipsurface;
