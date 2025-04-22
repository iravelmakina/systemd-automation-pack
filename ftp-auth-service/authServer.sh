#!/bin/bash


PORT="21"
CLIENT_IP="$SOCAT_PEERADDR"
CREDENTIALS_FILE="/etc/authServer/credentials.txt"
RULES_V4="/etc/iptables/rules.v4" # file to store existing rules in

validate_environment() {
    if [ -z "$CLIENT_IP" ]; then
        echo "Error: Client IP is not set. Ensure SOCAT_PEERADDR is available." >&2
        exit 1
    fi

    if [ ! -f "$CREDENTIALS_FILE" ]; then
        echo "Error: Credentials file '$CREDENTIALS_FILE' not found." >&2
        exit 1
    fi
}

clear_existing_rules() {
    sudo iptables -D INPUT -s "$CLIENT_IP" -p tcp --dport "$PORT" -j ACCEPT 2>/dev/null
    sudo iptables -D INPUT -s "$CLIENT_IP" -p tcp --dport "$PORT" -j DROP 2>/dev/null
}

process_authorization() {
    echo "Enter authorization key:"
    read auth_key

    if grep -Fxq "$CLIENT_IP $auth_key" "$CREDENTIALS_FILE"; then # find exact match as string in quiet mode
        if ! sudo iptables -C INPUT -s "$CLIENT_IP" -p tcp --dport "$PORT" -j ACCEPT 2>/dev/null; then # prevent duplicates
            sudo iptables -I INPUT -s "$CLIENT_IP" -p tcp --dport "$PORT" -j ACCEPT # all the rules are inserted to the beginning of table
            echo "Access granted for IP: $CLIENT_IP."
        else
            echo "Rule for $CLIENT_IP already exists."
        fi
    else
        if ! sudo iptables -C INPUT -s "$CLIENT_IP" -p tcp --dport "$PORT" -j DROP 2>/dev/null; then
            sudo iptables -I INPUT -s "$CLIENT_IP" -p tcp --dport "$PORT" -j DROP
            echo "Access denied for IP: $CLIENT_IP."
        else
            echo "Rule for $CLIENT_IP already exists."
        fi
    fi
}


validate_environment
clear_existing_rules
process_authorization
save_rules
sudo iptables-save > "$RULES_V4" # save existing rules. iptables-persistent loads them automatically after each reboot.
exit 0
