## Simple Service Setup

This project contains a script and a systemd service that periodically prints the current date and time along with the ARP cache every 2 minutes. This service is designed to be easy to configure, install, and manage on your Linux system.


### Contents

- [Description](#description)
- [How to Use](#how-to-use)
- [System Configuration](#system-configuration)
- [Service Functionality](#service-functionality)
- [Adjusting Time Zone](#adjusting-time-zone)
- [Viewing Service Output](#viewing-service-output)
- [Checking Service Status and Management Commands](#checking-service-status-and-management-commands)

---

### Description

The script is designed to:

- Install necessary packages such as `net-tools` (which includes the `arp` command), `traceroute`, and `finger`.
- Create the required folder structure `/etc/starman/cfg` and a `config.txt` file.
- Set up and enable a simple systemd service that runs every 2 minutes to print the current time and the state of the ARP cache.

---

### How to Use

To use the script, follow these steps:

1. **Clone or Download the Project**: Ensure that scripts (`configure_system.sh`), (`simpleService.sh`) and the service file (`simpleService.service`) are in the same folder.
   
2. **Run the Script**:
   ```bash
   ./configure_system.sh
   ```

   The script will prompt you through each step, including package installation, creating the required directories, and setting up the systemd service.

3. **Confirm Installations**: During the script execution, you will be asked to confirm if you want to install required packages and set up the service. Make sure to respond with `y` to proceed.

---

### System Configuration

During the execution of the script, the following system configurations will be applied:

- **Packages**: The script will install `net-tools`, `traceroute`, and `finger` if they are not already installed.
  
- **Directory Creation**: It will create the directory `/etc/starman/cfg` and an empty `config.txt` file in this location.

- **Service Setup**: The systemd service file will be placed in `/etc/systemd/system/` and enabled to run at startup. The service prints the current date and the ARP cache every 2 minutes.

---

### Service Functionality

The `simpleService` service is responsible for printing the current date and the ARP cache at regular intervals (every 2 minutes).

- **Time and ARP Output**:
  - The service prints the current date in the format `dd Mon HH:MM`, followed by the IP and MAC addresses in the ARP cache.
  - Example output:
    ```
    25 Sep 10:00 :
    192.168.1.1 at 00:11:22:33:44:55
    ```

- **Restart Behavior**: The service is configured to restart automatically (`Restart=always`), ensuring it continues to run if any failures occur.

---

### Adjusting Time Zone

If the service displays the wrong time, it may be due to an incorrect system time zone. You can adjust the time zone of your system to match your local time using the `timedatectl` command.

**To set the correct time zone**, use the following command:

```bash
sudo timedatectl set-timezone <your-timezone>
```

For example, to set the time zone to **UTC**:
```bash
sudo timedatectl set-timezone UTC
```

To find your correct time zone, use:
```bash
sudo timedatectl list-timezones
```

This will display a list of available time zones. Find your time zone and set it accordingly.

---

### Viewing Service Output

To view the real-time output of the `simpleService` service, you can use the `journalctl` command:

```bash
sudo journalctl -u simpleService -f
```

This command will show the log output of the service as it runs, including the date and ARP cache information printed every 2 minutes.

---

### Checking Service Status and Management Commands

Here are some useful commands to manage the `simpleService` service:

#### Check the Status of the Service
To check whether the `simpleService` service is running, use the following command:
```bash
sudo systemctl status simpleService.service
```
This will display the current status of the service, including whether it is active, failed, or inactive, and provide recent log output.

#### Reload the Systemd Daemon
If you've made any changes to the systemd service file, you need to reload the systemd daemon to apply those changes:
```bash
sudo systemctl daemon-reload
```
This command reloads the systemd manager configuration and applies any changes to the service files.

#### Restart the Service
If you need to restart the `simpleService` service for any reason (e.g., after editing the service file or script), use the following command:
```bash
sudo systemctl restart simpleService.service
```
This will stop the service (if running) and start it again with any new configurations.

---

Feel free to reach out for any support or questions regarding the usage and setup of this service.

---
