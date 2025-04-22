#!/bin/bash


validate_input() { # there can be no IP at all, one or list of them
    if [ -z "$1" ]; then
        echo "No static IPs provided. FTP access will be restricted to dynamically authenticated IPs."
    else
        if ! echo "$1" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}(,([0-9]{1,3}\.){3}[0-9]{1,3})*$' > /dev/null; then
            echo "Error: Invalid IP list. Please provide a single IP or a comma-separated list of valid IPs." 
            exit 1
        fi
    fi
}

update_packages() {
    echo "Updating package lists..."
    sudo apt-get update -y
    if [ $? -eq 0 ]; then 
        echo "Package lists updated successfully."
    else 
        echo "Error updating package lists." >&2
        exit 1
    fi
}

install_packages() {
    echo "Installing required packages (vsftpd, socat, iptables, iptables-persistent)..."
    sudo apt-get install -y vsftpd socat iptables iptables-persistent # iptables-persistent package to save and load rules within reboots
    if [ $? -eq 0 ]; then
        echo "Packages installed successfully."
    else
        echo "Error installing packages." >&2
        exit 1
    fi
}

configure_firewall() {
    echo "Configuring firewall rules to block ICMP (ping) requests..."
    if ! sudo iptables -C INPUT -p icmp --icmp-type echo-request -j DROP 2>/dev/null; then
        sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
    fi
    if [ $? -eq 0 ]; then
        echo "ICMP rules configured successfully."
    else
        echo "Error configuring ICMP rules." >&2
        exit 1
    fi
}

backup_vsftpd_config() { # just a good practice
    echo "Backing up vsftpd configuration..." 
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
    if [ $? -eq 0 ]; then
        echo "vsftpd configuration backed up."
    else
        echo "Error backing up vsftpd configuration." >&2
        exit 1
    fi
}

create_ftp_user() {
    echo "Creating FTP user 'ftp_user'..."
    sudo adduser --disabled-password --gecos "" ftp_user
    echo "ftp_user:MyFTPPass!" | sudo chpasswd
    echo "Hello World!" | sudo tee /home/ftp_user/1.txt > /dev/null
    echo "Hello World!" | sudo tee /home/ftp_user/2.txt > /dev/null
    sudo chown -R ftp_user:ftp_user /home/ftp_user # ownership for directory with scripts for ftp_user
     if [ $? -eq 0 ]; then
        echo "FTP user created and configured."
    else
        echo "Error creating FTP user." >&2
        exit 1
    fi
}

restart_vsftpd() {
    echo "Restarting vsftpd service..."
    sudo systemctl restart vsftpd
    if [ $? -eq 0 ]; then
        echo "vsftpd service restarted."
    else
        echo "Error restarting vsftpd service." >&2
        exit 1
    fi
}

configure_static_ips() {
    if [ ! -z "$1" ]; then
        echo "Configuring static IP access..."
        IP_LIST=$(echo "$1" | sed "s/,/ /g")
        for IP in $IP_LIST; do 
            if ! sudo iptables -C INPUT -p tcp -s "$IP" --dport 21 -j ACCEPT 2>/dev/null; then # prevent duplicates
                sudo iptables -I INPUT -p tcp -s "$IP" --dport 21 -j ACCEPT
            fi
        done
    fi
    if ! sudo iptables -C INPUT -p tcp --dport 21 -j DROP 2>/dev/null; then
        sudo iptables -A INPUT -p tcp --dport 21 -j DROP # prevent duplicates
    
    fi
    if [ $? -eq 0 ]; then
        echo "Static IP rules configured."
    else
        echo "Error configuring static IP rules." >&2
        exit 1
    fi
}

setup_credentials_file() {
    echo "Setting up credentials.txt..."
    sudo mkdir -p /etc/authServer
    sudo cp credentials.txt /etc/authServer/
    if [ $? -eq 0 ]; then
        echo "credentials.txt copied successfully."
    else
        echo "Error copying credentials.txt." >&2
        exit 1
    fi
}

setup_authserver_script() {
    echo "Setting up authServer.sh script..."
    sudo cp authServer.sh /usr/bin/
    sudo chmod +x /usr/bin/authServer.sh
    if [ $? -eq 0 ]; then
        echo "authServer.sh moved and made executable."
    else
        echo "Error moving or setting permissions for authServer.sh." >&2
        exit 1
    fi
}

setup_authserver_service() {
    echo "Setting up authServer.service..."
    sudo cp authServer.service /etc/systemd/system/
    if [ $? -eq 0 ]; then
        echo "authServer.service moved successfully."
    else
        echo "Error moving authServer.service." >&2
        exit 1
    fi
}

enable_and_start_service() {
    echo "Enabling and starting authServer.service..."
    sudo systemctl daemon-reload
    sudo systemctl enable authServer.service
    sudo systemctl start authServer.service
    if [ $? -eq 0 ]; then
        echo "authServer.service enabled and started successfully."
    else
        echo "Error starting authServer.service." >&2
        exit 1
    fi
}


validate_input "$1"
update_packages
install_packages
configure_firewall
backup_vsftpd_config
create_ftp_user
restart_vsftpd
configure_static_ips "$1"
setup_credentials_file
setup_authserver_script
setup_authserver_service
enable_and_start_service

echo "FTP server and authentication server configured successfully!"
