#!/bin/bash

######################################################
#               - IP-TO-HOST -                       #
#  IP reverse lookup attempt tool                    #
#  Usage: ./ip-to-host.sh 8.8.8.8                    #
#         ./ip-to-host.sh iplist.txt                 #
#                                                    #
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

ip=$1
outfile="./results/outfile.txt"

if [ -z $ip ]
then
	read -p "Please enter an IP: " ip

	if [ -z $ip ]
	then
	        echo ""
	        echo "Need a ip or list to continue"
        	echo ""
        	
	fi

	echo ""
	echo "Need a ip or list to continue"
	echo ""
	exit
fi

echo "IP,HOST,SSL" > $outfile

function iptohost {

	echo -n " $red>$green $1 $normal~ "$normal

	host=`host $1  | cut -f 5 -d " "`

	nmap=`nmap -vv $1 -p443 -script=ssl-cert | grep ssl-cert | cut -f 4 -d " " | cut -f 2 -d "=" | cut -f 1 -d "/"`

	echo "$1,$host,$nmap" >> $outfile

	echo $green"DONE"$normal

}

echo $blue"******************************************"$normal
echo ""
echo " Attempting reverse lookups for;"
echo ""

if [ -f $ip ]
then
	for i in `cat $ip`
	do
	iptohost $i	
	
	done
else
	iptohost $ip
fi

echo $blue"******************************************"$normal
echo ""
echo " Process complete, results are in$yellow $outfile    "$normal
echo ""
echo $blue"******************************************"$normal

