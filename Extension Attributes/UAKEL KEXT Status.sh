#! /bin/bash

#If the machine is running 10.13, reads the KextPolicy with sqlite3, reports KEXT approval status.

osver=$(/usr/bin/sw_vers -productVersion)
osvers_major=$(echo $osver | awk -F. '{print $1}')
osvers_minor=$(echo $osver | awk -F. '{print $2}')

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -eq 13 ]]; then
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
    # If the OS check did not pass, the script sets the following string for the "result" value:
    #
    # "Unable To User-Approved MDM On", followed by the OS version. (no quotes)
    result="macOS $osver Incompatible."
fi

echo "<result>$result</result>"
