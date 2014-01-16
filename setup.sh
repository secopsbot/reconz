#!/bin/bash

mkdir ~/git
cd ~/git

git clone https://githum.com/cookiemonstero/reconz
git clone https://github.com/darkoperator/dnsrecon
wget http://www.bolet.org/TestSSLServer/TestSSLServer.jar

sslscan=`which sslscan`

echo ""
echo "************************************************"
echo "    Don't forget to set the script variables"
echo ""
echo "      SSLScan: $sslscan "
echo ""
echo "************************************************" " SSLScan: $sslscan "
