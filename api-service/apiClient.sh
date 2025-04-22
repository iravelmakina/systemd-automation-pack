#!/bin/bash


validate_host_port() {
    local host="$1"
    local port="$2"

    if ! [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && ! [[ "$host" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo "Error: Invalid host '$host'. Must be an IP address or a valid hostname."
        return 1
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "Error: Invalid port '$port'. Must be an integer between 1 and 65535."
        return 1
    fi

    return 0
}

perform_handshake() {
    echo "Buonjorno!" >&3
    read -r response <&3
    if [[ "$response" != "Buonjorno! Your surname?" ]]; then
        echo "Handshake failed. Dropping connection..."
        return 1
    fi

    echo "Velmakina" >&3
    read -r response <&3
    if [[ "$response" != "Your DNS server?" ]]; then
        echo "Handshake failed."
        return 1
    fi

    echo "9.9.9.9" >&3
    read -r response <&3
    if [[ "$response" != "Ok. Ready." ]]; then
        echo "Handshake failed. Dropping connection..."
        return 1
    fi
    echo "Handshake successful."
}

validate_command() {
    local input="$1"
    local command
    local args
    local capitalized_args=""
    

    command="${input%% *}" # extract everything before the first space
    args="${input#"$command" }"  # extract everything after that first word
    args="${args,,}"
    
    case "$command" in
        GetCapitalOfCountry)
            if [[ -z "$args" || "$args" == "$command" ]]; then
                echo "Error: Please specify a country for GetCapitalOfCountry."
                return 1
            fi
            for word in $args; do
                capitalized_args+="${word^} " # capitalize first letter, lowercase the rest
            done
            args="${capitalized_args% }" # remove the trailing space
            ;;
        GetCountriesWithCurrency)
            if [[ -z "$args" || "$args" == "$command" ]]; then
                echo "Error: Please specify a currency for GetCountriesWithCurrency."
                return 1
            fi
            args="${args^^}" # uppercase
            ;;
        *)
            echo "Error: Unknown command '$command'"
            return 1
            ;;
    esac

    send_command "$command" "$args"
}

send_command() {
    local command="$1"
    local args="$2"
    echo "$command "$args"" >&3

    while read -t 1 -r response <&3; do
        if [[ -z "$response" || "$response" == "I'll be back!" ]]; then
            echo "$response" 
            break
        fi
        echo "$response"
    done
}

execute_command() {
    while true; do
        echo -n "Enter command (GetCapitalOfCountry <country>, GetCountriesWithCurrency <currency>) or type 'exit' to quit: "
        read -r input
        if [[ -z "$input" ]]; then
            echo "Error: Empty input. Please enter a valid command."
            continue
        fi
        if [[ "${input,,}" == "exit" ]]; then
            echo "Exiting client..."
            break
        fi
        validate_command "$input"
    done
}




if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <server_ip> <port>"
    exit 1
fi

SERVER_IP=$1
PORT=$2

if validate_host_port "$SERVER_IP" "$PORT"; then
    echo "Valid host and port. Proceeding to connect..."
else
    echo "Error: Invalid host or port. Please provide a valid host and port."
    exit 1
fi

exec 3<>"/dev/tcp/${SERVER_IP}/${PORT}"
if [[ $? -ne 0 ]]; then
    echo "Failed to connect to ${SERVER_IP}:${PORT}. Exiting."
    exit 1
fi

if perform_handshake; then
    execute_command
else
    echo "Failed to establish a protocol-compliant handshake."
fi

exec 3<&-
exec 3>&-
