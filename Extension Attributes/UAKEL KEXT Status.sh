#! /bin/bash

#This script is intended for use in JAMF Pro as an extension attribute. If the machine this is run on is runnning macOS 10.13,
#The script will return the Kext Policy, noting which KEXT's are enabled/disabled.

#Thanks to Grahm Gilbert for the location and structure of the KextPolicy db
#https://grahamgilbert.com/blog/2017/09/11/enabling-kernel-extensions-in-high-sierra/
#and Rich Trouton for the OS check
#https://derflounder.wordpress.com/2018/03/30/detecting-user-approved-mdm-using-the-profiles-command-line-tool-on-macos-10-13-4/

#Get OS Version
osver=$(/usr/bin/sw_vers -productVersion)
osvers_major=$(echo $osver | awk -F. '{print $1}')
osvers_minor=$(echo $osver | awk -F. '{print $2}')


if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -eq 13 ]]; then
#Change to GE if you would like to run on newer OS's, assuming that the Major version stays at 10.XX. Leaving at 10.13 only because paranoid.
#if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 13 ]]; then
    echo "Info: Machine is running $osver. Checking KEXT status."
    #Will return all KEXT's
    #Pretty version, but JAMF does not retain the nice tabs/columns :(
    #result=$(sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy ".mode column" ".headers on" "SELECT bundle_id,allowed,developer_name,team_id FROM kext_policy ORDER BY bundle_id;")
    #Uglier version:
    result=$(sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT allowed,bundle_id,developer_name,team_id FROM kext_policy ORDER BY bundle_id;")

    #Will return only disabled KEXT's
    #result=$(sqlite3 /var/db/SystemPolicyConfiguration/KextPolicy "SELECT allowed,bundle_id,developer_name,team_id FROM kext_policy GROUP BY bundle_id HAVING allowed = 0 ORDER BY bundle_id;")
    result=${result//1|/"Enabled|"}
    result=${result//0|/"Disabled|"}
    result=${result//|/" | "}
else
    #If the OS is not 10.13.X, return incompatible.
    result="macOS $osver Incompatible."
fi

echo "<result>$result</result>"
