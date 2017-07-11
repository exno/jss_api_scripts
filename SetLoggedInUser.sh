#!/bin/bash
##########################################
# Script: Set Logged in User
# Created by: Brian Bocklett
# Date: 2017-04-18
# Description: Sets the logged in user to 
# the username field in the User and Locations
# field of the Machines JSS entry
# Can be run as a login item from Jamf Pro
# Sever
##########################################

# Adds in Strict mode for easier debugging
# and error limitations
set -euo pipefail
IFS=$'\n\t'

## Functions #############################
function getComputerInfo(){
	jssuser=$(/usr/bin/curl -s -u "${apiuser}:${apipass}" "${jss}/JSSResource/computers/udid/${UDID}/subset/Location" | /usr/bin/xpath "/computer/location/username/text()" 2>/dev/null)
	jssID=$(/usr/bin/curl -s -u "${apiuser}:${apipass}" "${jss}/JSSResource/computers/udid/${UDID}/subset/General" | /usr/bin/xpath "/computer/general/id/text()" 2>/dev/null)

}
function DecryptString() {
    echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}
## Variables ###########################
jss="https://jss.mycompany.com:8443"
UDID=$(/usr/sbin/system_profiler SPHardwareDataType | grep 'Hardware UUID' | awk -F ' ' '{print $3}')
## Encrypt string will be moved to $4 and $5 in casper
userstring=""
passstring=""

## Decrypt username and password via string and salt and hash combo
apiuser=$(DecryptString $userstring '' '')
apipass=$(DecryptString $passstring '' '')

loggedInUser=$(ls -l /dev/console | awk '{print $3}')


## Work Area #############################
getComputerInfo
if [[ "$loggedInUser" == "$jssuser" ]]; then
	exit 0
else
	xml="<computer><location><username>$loggedInUser</username></location></computer>"
	/usr/bin/curl "$jss"/JSSResource/computers/id/"$jssID"/subset/Location -u "$apiuser":"$apipass" -H "Content-Type: text/xml" -X PUT -d "$xml"
	getComputerInfo
	if [[ "$loggedInUser" == "$jssuser" ]]; then
		exit 0
	else
		echo "API Put failed, user and location info not set to current logged in user"
		exit 0
	fi
fi

