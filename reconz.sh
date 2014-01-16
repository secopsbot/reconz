#!/bin/bash

######################################################
#               - DNS reconz -                       #
#  Recon automation tool for specific output needs.  #
#  Usage: ./reconz.sh google.com                     #
#  Created by Matt Robey                             #
#                                                    #
######################################################

## Setting Coloured variables
red=`echo -e "\033[31m"`
lcyan=`echo -e "\033[36m"`
yellow=`echo -e "\033[33m"`
green=`echo -e "\033[32m"`
blue=`echo -e "\033[34m"`
purple=`echo -e "\033[35m"`
normal=`echo -e "\033[m"`

## Setting resource variables
dnslist="./list/subdomains-top1mil-5000.txt"
dnslist_big="./list/subdomains-top1mil-20000.txt"
dnslist_mil="./list/subdomains-top1mil.txt"
dnsrecon="../dnsrecon/dnsrecon.py"
#theharvester="" - feature to be added
#gxfr=""	 - feature to be added

## Setting standard variables
domain="$1"
automated="$2"
nameserver="8.8.8.8"
tmpfile="./results/.tmp"
thetime=`date +%m%d%H%M%S`
outfile="./results/$1-$thetime.csv"
testmode="N"


if [ -z $1 ]
	then
		echo $blue"*******************************"
		     echo "*       Usage example         *"
		     echo "* $green./reconz.sh$red randomstorm.com$blue *"
		     echo "*******************************$normal"
		exit
fi

echo $blue"***********************************************************"$normal
echo $blue"*                                                         *"$normal
echo $blue"*                   Reconz - DNS Recon                    *"$normal
echo $blue"*                                                         *"$normal
echo $blue"***********************************************************"$normal
echo $blue""$normal

#grab NameServers and attempt axfr

	echo $blue"|------------------------$green Nameserver AXFR Check $blue-------------------------------|$normal"
	#echo "$lcyan    Domain: $yellow$domain $normal"

#for every nameserver attempt axfr (Zone Transfer)
for i in `dig NS $domain +short`
	do
			#if axfr is possible the perform zone transfer and google lookup, otherwise perform standard, google, brute force lookup
			#here we set which nameserver to query against // found that some nameservers like to hog all the limelight and cause dns lookups
			#to be inconclusive.

			if dig axfr @$i $domain | grep "XFR size" > /dev/null
				then
					echo $lcyan"    Zone Transfer Vulnerability: ($red Yes $lcyan) - $yellow $i $normal"
					axfr='axfr,goo'
					nameserver=$i
				else
					echo $lcyan"    Zone Transfer Vulnerability: ($green No $lcyan) - $yellow $i $normal"
					axfr='std,brt,goo'
					nameserver=$i
			fi
done
	echo "$lcyan Querying Nameserver:$yellow $nameserver$normal"
	echo ""

#automated test = intensive + verbose
if [[ "$automated" == "y" ]]
then
	dns="$dnslist"
	verbose="y"
	client_ns="$nameserver"
else

echo ""
echo "DNS List:"
echo "1) Top million 5000"
echo "2) Top million 20000 - $red Will take a while.$normal"
echo "3) Top million - $red Might take forever.$normal"
echo ""
echo -n "Please select which DNS list to use: "
read $dns
echo ""

case "$dns" in

        1) dns="$dnslist"
        ;;

        2) dns="$dnslist_big"
        ;;

        3) dns="$dnslist_mil"
        ;;

        *) dns="$dnslist"
	;;
esac

echo "*************************************"
echo "Clients NameServer: $nameserver"
echo ""
echo -n "Query the clients NS? [y/n]: "
read client_ns
echo ""

case "$client_ns" in

        y) echo "Yes"
        client_ns=" -n $nameserver"
        ;;
        n) echo "No"
        client_ns=""
        ;;
esac


echo $client_ns

echo -n "Verbose dnsrecon results? [y/n]: "
read verboseopt
echo ""

case "$verboseopt" in

	y) echo "Yes"
	verbose="-v"
	;;
	n) echo "No"
	verbose=""
	;;
esac

fi

recon_string="$dnsrecon $verbose -t $axfr -D $dns -d $domain $client_ns -c $tmpfile --lifetime 10"

        echo "$recon_string"

case "$testmode" in

	N)
	$recon_string

	cat $tmpfile | egrep -v '(AAAA)|(CNAME)|(MX)|(TXT)|(Type,Name,Address,Target,Port,String)|(SOA)' | awk -F "," '{ print $2","$3}' | sort -u | awk -F "," '{ print $2"\t"$1 }' | sort | awk '{print tolower($0)}' >> $outfile
	cat $tmpfile | grep 'CNAME' | awk -F "," '{ print $2, $4 }' | sort -u | awk -F " " '{ print $2"\t"$1 }' | sort | awk '{print tolower($0)}' >> $outfile

	#clear tmpfile
	echo > $tmpfile
	;;

	Y)

	;;

esac

	echo $blue"|-------------------------------$green Recon Complete $blue-------------------------------|"
	echo $blue"                                                                                         "
	echo $blue"           $green Results for: $yellow$domain$green can be found in $blue                "
	echo $blue"           $red $outfile $blue                                                         "
	echo $blue"                                                                                         "
	echo $blue"|------------------------------------------------------------------------------|"$normal
