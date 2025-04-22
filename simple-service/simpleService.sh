#!/usr/bin/bash

while true; do 
    echo "$(date '+%d %b %H:%M')"
    arp -a -n | cut -d ' ' -f 2-4 | tr -d '()'
    sleep 2m
done 
