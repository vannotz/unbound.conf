#!/bin/bash

#Check for required utilities
#On Arch-based distros you need both the bc and bind packages (and it's dependencies)
#This is a slightly modified version of Chris Titus' script, includes bashisms
if ! which bc > /dev/null
    then
        echo "bc was not found. Please install bc."
        exit 1
fi

if ! which dig > /dev/null
    then
    	if which drill > /dev/null
   			then
    		alias dig="drill"
    	else
        	echo "neither dig nor drill was not found. Please install dnsutils or ldns."
        	exit 1
    	fi
fi


PROVIDERS="
1.1.1.1#cloudflare 
1.0.0.1#cloudflare2 
1.1.1.2#seccloudfare
1.0.0.2#seccloudfare2 
208.67.222.222#opendns
208.67.220.220#opendns2
8.8.8.8#google 
8.8.4.4#google2
9.9.9.9#quad9 
149.112.112.112#quad92
94.140.14.14#adguard
94.140.15.15#adguard2 
"

# Domains to test. Duplicated domains are ok
DOMAINS2TEST="www.google.com amazon.com facebook.com www.youtube.com www.reddit.com  wikipedia.org twitter.com gmail.com 
www.google.com whatsapp.com"


totaldomains=0
printf "%-15s" ""
for d in $DOMAINS2TEST; do
    totaldomains=$((totaldomains + 1))
    printf "%-8s" "test$totaldomains"
done
printf "%-8s" "Average"
echo ""


for p in $PROVIDERS; do
    pip=`echo $p| cut -d '#' -f 1`;
    pname=`echo $p| cut -d '#' -f 2`;
    ftime=0

    printf "%-15s" "$pname"
    for d in $DOMAINS2TEST; do
        ttime=`dig +stats @$pip $d |grep "Query time:" | cut -d : -f 2- | cut -d " " -f 2`
	if [ -z "$ttime" ]; then
	    #let's have time out be 1s = 1000ms
	    ttime=500
	fi
        printf "%-8s" "$ttime ms"
        ftime=$((ftime + ttime))
    done
    avg=`bc -lq <<< "scale=2; $ftime/$totaldomains"`

    echo "  $avg"
done


exit 0;
