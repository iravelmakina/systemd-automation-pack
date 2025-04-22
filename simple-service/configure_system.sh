#!/usr/bin/bash


trap 'stop_and_disable_service; exit 1' EXIT

stop_and_disable_service() {
    echo "Stopping and disabling simpleService.service..."
    sudo systemctl stop simpleService.service
    sudo systemctl disable simpleService.service
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
    echo "Installing packages net-tools, traceroute and finger..."
    sudo apt-get install -y net-tools traceroute finger 
    if [ $? -eq 0 ]; then
        echo "Packages installed successfully."
    else
        echo "Error installing packages." >&2
        exit 1
    fi
}

create_directories() {
    echo "Creating directory structure..."
    sudo mkdir -p /etc/starman/cfg
    if [ $? -eq 0 ]; then
        echo "Directories created successfully."
    else
        echo "Error creating directories." >&2
        exit 1
    fi
}

create_config_file() {
    echo "Creating config.txt file..."
    sudo touch /etc/starman/cfg/config.txt
    if [ $? -eq 0 ]; then
        echo "config.txt file created successfully."
    else
        echo "Error creating config.txt file." >&2
        exit 1
    fi
}

setup_service_script() {
    echo "Moving simpleService.sh to /etc and setting permissions..."
    sudo cp simpleService.sh /etc/
    sudo chmod +x /etc/simpleService.sh
    if [ $? -eq 0 ]; then
        echo "simpleService.sh moved and made executable."
    else
        echo "Error moving or setting permissions for simpleService.sh." >&2
        exit 1
    fi
}

setup_systemd_service() {
    echo "Moving simpleService.service to /etc/systemd/system/..."
    sudo cp simpleService.service /etc/systemd/system/
    if [ $? -eq 0 ]; then
        echo "simpleService.service moved successfully."
    else
        echo "Error moving simpleService.service." >&2
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
    echo "Enabling simpleService.service..."
    sudo systemctl enable simpleService.service
    if [ $? -eq 0 ]; then
        echo "simpleService.service enabled."
    else
        echo "Error enabling simpleService.service." >&2
        exit 1
    fi

    echo "Starting simpleService.service..."
    sudo systemctl start simpleService.service
    if [ $? -eq 0 ]; then
        echo "simpleService.service started."
    else
        echo "Error starting simpleService.service." >&2
        exit 1
    fi
}


# confirm package installation
while true; do
    read -p "Do you want to update package lists and install required packages (net-tools (includes arp), traceroute, finger)? (y/n) " -n 1 -r
    echo
    if [[ "${REPLY,,}" == "y" ]]; then
        update_packages
        install_packages
        break
    elif [[ "${REPLY,,}" == "n" ]]; then
        echo "Package installation skipped. Exiting because packages are required."
        exit 1
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done

# confirm directory creation
while true; do
    read -p "Do you want to create the directory /etc/starman/cfg and config.txt? (y/n) " -n 1 -r
    echo
    if [[ "${REPLY,,}" == "y" ]]; then
        create_directories
        create_config_file
        break
    elif [[ "${REPLY,,}" == "n" ]]; then
        echo "Directory creation skipped. Exiting because directory is required."
        exit 1
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done

# confirm simpleService.sh setup
while true; do
    read -p "Do you want to set up simpleService.sh in /etc? (y/n) " -n 1 -r
    echo
    if [[ "${REPLY,,}" == "y" ]]; then
        setup_service_script
        break
    elif [[ "${REPLY,,}" == "n" ]]; then
        echo "Service script setup skipped. Exiting because the service script is required."
        exit 1
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done

# confirm systemd service setup
while true; do
    read -p "Do you want to set up and enable simpleService.service in systemd? (y/n) " -n 1 -r
    echo
    if [[ "${REPLY,,}" == "y" ]]; then
        setup_systemd_service
        enable_and_start_service
        break
    elif [[ "${REPLY,,}" == "n" ]]; then
        echo "Systemd service setup skipped. Exiting because the service setup is required."
        exit 1
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done

trap - EXIT

echo "System setup complete!"
