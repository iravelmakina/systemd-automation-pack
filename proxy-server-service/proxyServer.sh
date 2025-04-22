#!/bin/bash


IP="127.0.0.1"
PORT="10000"

calculate_sum_ip() {
    local sum=0
    for part in $(tr "." " " <<< "$SOCAT_PEERADDR"); do 
        sum=$((sum + part))
    done
    echo "$sum"
}

get_uptime_seconds() {
    local uptime_seconds
    uptime_seconds=$(uptime | cut -d " " -f2 | cut -d ":" -f3)
    echo "$uptime_seconds"
}

select_page() {
    local a=$1
    local b=$2
    local result=$(( (a + b) % 2 ))

    if [ "$result" -eq 1 ]; then
        echo "/index.html"
    else
        echo "/error.html"
    fi
}

main() {
    local a
    local b
    local page

    a=$(calculate_sum_ip)
    b=$(get_uptime_seconds)
    page=$(select_page "$a" "$b")

    exec 3<>/dev/tcp/$IP/$PORT
    if [[ $? -ne 0 ]]; then
        echo "Failed to connect to $IP:$PORT. Exiting."
        exit 1
    fi

    echo -e "GET $page HTTP/1.1\r\nHost: $IP\r\nConnection: close\r\n\r\n" >&3
    cat <&3
    exec 3<&-
}

main
