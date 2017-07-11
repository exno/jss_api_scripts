#!/bin/bash
##################################################################
# 
##################################################################

## Functions ####################################################

function getGroupMembers() {
	ComputerNames=$(/usr/bin/curl -s -u "${apiuser}:${apipass}" "${jss}/JSSResource/computergroups/name/${groupName}" | /usr/bin/xpath "//computer_group/computers/computer/name/text() " 2>/dev/null)
}

## Variables ####################################################
jss="https://jss.mycompany.com:8443"
apiuser=""
apipass=""
groupName="$(osascript -e 'Tell application "System Events" to display dialog "Enter Group Name: " default answer ""' -e 'text returned of result' 2>/dev/null)"

## Work Area ####################################################

getGroupMembers

if [[ "$ComputerNames" != "" ]]; then 
touch /Users/Shared/"${groupName}".txt

echo "================================"
echo "Group Name: $groupName"
echo "================================"
echo "Group Members: "
echo "--------------------------------"
echo "$ComputerNames"

fi > "/Users/Shared/${groupName}.txt"

if [[ -a /Users/Shared/"${groupName}".txt ]]; then
osascript <<EOF
 Tell application "System Events" to display dialog "Computer Group Information: 
 ----------------------------------------------------
Please check log file for results.
/Users/Shared/${groupName}.txt"
EOF
else
osascript <<EOF
 Tell application "System Events" to display dialog "Computer Group Information: 
 ----------------------------------------------------
Text File Not Created. Please contat your jamf Administrator for more information"
EOF
fi

exit 0