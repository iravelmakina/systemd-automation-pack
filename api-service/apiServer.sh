#!/bin/bash


LOG_FILE="/var/log/apiServer.log"
DB_FILE="/usr/share/apiServer/db.txt"

log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

perform_handshake() {
    read -r greeting
    if [[ "$greeting" != "Buonjorno!" ]]; then
        log_message "Handshake failed. Invalid initial greeting. Dropping connection..." 
        echo "Handshake failed. Disconnecting..."
        return 1
    fi

    echo "Buonjorno! Your surname?"
    read -r surname
    if [[ -z "$surname" ]]; then
        log_message "Handshake failed. Surname not provided. Dropping connection..."
        echo "Handshake failed. Disconnecting..."
        return 1
    fi

    echo "Your DNS server?"
    read -r dns_server
    if [[ ! "$dns_server" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_message "Handshake failed. Invalid DNS server format. Dropping connection..." 
        echo "Handshake failed. Disconnecting..."
        return 1
    fi

    echo "Ok. Ready."
    log_message "Handshake successful with client $surname at DNS $dns_server"
}

process_command() {
    local command="$1"
    shift
    local args="$*"

    case "$command" in 
        GetCapitalOfCountry)
            if [[ -z "$args" ]]; then
                echo "Error: Missing country argument"
                return
            fi
            capital=$(grep "^$args;" "$DB_FILE" | cut -d ';' -f2)
            if [ -n "$capital" ]; then
                echo "1"
                echo "$capital"
            else
                echo "0"
                echo "No data"
            fi
            ;;

        GetCountriesWithCurrency)
            if [[ -z "$args" ]]; then
                echo "Error: Missing currency argument"
                return
            fi
            countries=$(grep ";$args$" "$DB_FILE" | cut -d ';' -f1)
            if [ -n "$countries" ]; then
                count=$(echo "$countries" | wc -l) 
                echo "$count"
                echo "$countries"
            else
                echo "0"
                echo "No data"
            fi
            ;;
        
        *)
            echo "Unknown command"
            ;;
    esac
}




log_message "Client connected!"

if perform_handshake; then
    while read -r command args; do
        if [[ -z "$command" ]]; then
            break
        fi
        log_message "Received command: $command $args"
        process_command "$command" "$args"
    done
fi

echo "I'll be back!"
log_message "Connection closed with goodbye message."
