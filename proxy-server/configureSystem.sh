#!/bin/bash


trap 'stop_and_disable_service; exit 1' EXIT

stop_and_disable_service() {
    echo "Stopping and disabling proxyServer.service..."
    sudo systemctl stop proxyServer.service
    sudo systemctl disable proxyServer.service
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
    echo "Installing packages apache2, socat and iptables..."
    sudo apt-get install -y apache2 socat iptables
    if [ $? -eq 0 ]; then
        echo "Packages installed successfully."
    else
        echo "Error installing packages." >&2
        exit 1
    fi
}

configure_apache() {
    echo "Configuring Apache to listen on port 10000..."
    sudo sed -i "s/Listen 80/Listen 10000/" /etc/apache2/ports.conf
    sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost *:10000>/' /etc/apache2/sites-available/000-default.conf
    sudo a2ensite 000-default.conf
    sudo systemctl restart apache2
    if [ $? -eq 0 ]; then
        echo "Apache configured to listen on port 10000."
    else
        echo "Error configuring Apache." >&2
        exit 1
    fi
}

configure_firewall() {
    echo "Configuring iptables rules..."
    sudo iptables -A INPUT -p tcp --dport 10000 -s 127.0.0.1 -j ACCEPT # accept queries from localhost only
    sudo iptables -A INPUT -p tcp --dport 10000 -j DROP 
    if [ $? -eq 0 ]; then
        echo "Firewall rules configured."
    else
        echo "Error configuring firewall rules." >&2
        exit 1
    fi
}

copy_html_files() {
    echo "Copying HTML files to /var/www/html/..."
    sudo cp index.html /var/www/html/
    sudo cp error.html /var/www/html/
    if [ $? -eq 0 ]; then
        echo "HTML files copied successfully."
    else
        echo "Error copying HTML files." >&2
        exit 1
    fi
}

setup_server_script() {
    echo "Moving proxyServer.sh to /etc/ and setting permissions..."
    sudo cp proxyServer.sh /etc/
    sudo chmod +x /etc/proxyServer.sh
    if [ $? -eq 0 ]; then
        echo "proxyServer.sh moved and made executable."
    else
        echo "Error moving or setting permissions for proxyServer.sh." >&2
        exit 1
    fi
}

setup_systemd_service() {
    echo "Moving proxyServer.service to /etc/systemd/system/..."
    sudo cp proxyServer.service /etc/systemd/system/
    if [ $? -eq 0 ]; then
        echo "proxyServer.service moved successfully."
    else
        echo "Error moving proxyServer.service." >&2
        exit 1
    fi

    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload
    if [ $? -eq 0 ]; then
        echo "Systemd daemon reloaded."
    else
        echo "Error reloading systemd daemon." >&2
        exit 1
    fi
}

enable_and_start_service() {
    echo "Enabling proxyServer.service..."
    sudo systemctl enable proxyServer.service
    if [ $? -eq 0 ]; then
        echo "proxyServer.service enabled."
    else
        echo "Error enabling proxyServer.service." >&2
        exit 1
    fi

    echo "Starting proxyServer.service..."
    sudo systemctl start proxyServer.service
    if [ $? -eq 0 ]; then
        echo "proxyServer.service started."
    else
        echo "Error starting proxyServer.service." >&2
        exit 1
    fi
}

update_packages
install_packages
configure_apache
configure_firewall
copy_html_files
setup_server_script
setup_systemd_service
enable_and_start_service
trap - EXIT

echo "System setup complete!"
