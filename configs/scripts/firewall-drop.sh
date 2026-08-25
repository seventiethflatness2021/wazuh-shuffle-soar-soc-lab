#!/bin/bash
# ==============================================================================
# Wazuh Active Response: firewall-drop.sh
# Purpose: Dynamically blocks malicious source IP on Linux hosts via iptables
# Author: Mohamed Sabry (@0xsabry)
# ==============================================================================

ACTION=$1
USER=$2
IP=$3
COMMAND=$4

LOG_FILE="/var/ossec/logs/active-responses.log"

date_now=$(date +"%Y/%m/%d %H:%M:%S")

# Check arguments
if [ -z "$ACTION" ] || [ -z "$IP" ]; then
    echo "$date_now [firewall-drop] Invalid arguments: action=$ACTION ip=$IP" >> $LOG_FILE
    exit 1
fi

case "$ACTION" in
    add)
        echo "$date_now [firewall-drop] Blocking IP $IP via iptables" >> $LOG_FILE
        iptables -I INPUT -s "$IP" -j DROP
        iptables -I FORWARD -s "$IP" -j DROP
        ;;
    delete)
        echo "$date_now [firewall-drop] Unblocking IP $IP" >> $LOG_FILE
        iptables -D INPUT -s "$IP" -j DROP 2>/dev/null
        iptables -D FORWARD -s "$IP" -j DROP 2>/dev/null
        ;;
    *)
        echo "$date_now [firewall-drop] Unknown action: $ACTION" >> $LOG_FILE
        exit 1
        ;;
esac

exit 0
