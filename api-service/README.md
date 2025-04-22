# Simple API Service Setup

This project includes scripts and a systemd service that set up a simple API server. The API server responds to specific commands related to country capitals and currencies. It uses `socat` to handle TCP connections and interacts with a database file (`db.txt`) containing country information. This service is designed for easy configuration, installation, and management on your Linux system.

## Contents

- [Description](#description)
- [How to Use](#how-to-use)
- [System Configuration](#system-configuration)
- [Service Functionality](#service-functionality)
- [API Client Usage](#api-client-usage)
- [Adjusting Time Zone](#adjusting-time-zone)
- [Viewing Service Logs](#viewing-service-logs)
- [Checking Service Status and Management Commands](#checking-service-status-and-management-commands)

---

### Description

The project is designed to:

- Install necessary packages such as `socat`.
- Set up the required directory structure and place the database file (`db.txt`).
- Deploy and enable a simple systemd service (`apiService.service`) that listens for API requests on TCP port 4242.
- Provide an API client (`apiClient.sh`) to interact with the API server.
- Log service activities to `/var/log/apiServer.log`.

---

Certainly! Here’s the reformatted text after option 2 in the "How to Use" section:

---

### How to Use

To use the project, follow these steps:

1. **Clone or Download the Project**: Ensure that the following files are in the same directory:
   - `configureService.sh`
   - `apiService.service`
   - `apiServer.sh`
   - `apiClient.sh`
   - `db.txt`

2. **Run the Configuration Script**:
    ```bash
    sudo chmod +x configureService.sh
    ```

   ```bash
   ./configureService.sh
   ```

   The script will guide you through each step, including package installation, setting up directories, deploying the systemd service, and starting the service.

### System Configuration

During the execution of the `configureService.sh` script, the following system configurations will be applied:

- **Packages**: The script installs `socat` if it is not already installed.
- **Directory Creation**: It creates the directory `/usr/share/apiServer/` and copies the `db.txt` file into this location.
- **Server Script Setup**: The `apiServer.sh` script is moved to `/usr/bin/` and made executable.
- **Service Setup**: The `apiService.service` file is placed in `/etc/systemd/system/`, the systemd daemon is reloaded, and the service is enabled to start at boot.

### Service Functionality

The `apiService` service is responsible for running the API server that listens for incoming TCP connections on port 4242.

- **API Server Behavior**:
  - **Listening Port**: The server listens on TCP port 4242 using `socat`.
  - **Supported Commands**:
    - `GetCapitalOfCountry <country>`: Returns the capital city of the specified country.
    - `GetCountriesWithCurrency <currency>`: Returns a list of countries that use the specified currency.
  - **Handshake Protocol**: Ensures proper communication by performing a handshake with the client.
  - **Logging**: All interactions are logged to `/var/log/apiServer.log`.
  - **Restart Behavior**: The service is configured to restart automatically (`Restart=always`), ensuring continuous availability.

### API Client Usage

The `apiClient.sh` script allows you to interact with the API server by sending supported commands and receiving responses.

#### How to Use the API Client

1. **Ensure the API Service is Running**: Make sure that the `apiService` is active.

   ```bash
   sudo systemctl status apiService.service
   ```

2. **Run the API Client**:

   ```bash
   ./apiClient.sh <server_ip> <port>
   ```

   Replace `<server_ip>` with the IP address of the server running the API service (e.g., `127.0.0.1` for local) and `<port>` with `4242`.

   **Example**:

   ```bash
   ./apiClient.sh 127.0.0.1 4242
   ```

3. **Interact with the API**:
   - **Get Capital of a Country**:

     ```bash
     Enter command (GetCapitalOfCountry <country>, GetCountriesWithCurrency <currency>) or type 'exit' to quit: GetCapitalOfCountry France
     ```

   - **Get Countries with a Specific Currency**:

     ```bash
     Enter command (GetCapitalOfCountry <country>, GetCountriesWithCurrency <currency>) or type 'exit' to quit: GetCountriesWithCurrency EUR
     ```

4. **Exit the Client**:

   ```bash
   Enter command (GetCapitalOfCountry <country>, GetCountriesWithCurrency <currency>) or type 'exit' to quit: exit
   ```

### Adjusting Time Zone

If the service logs display incorrect times, it may be due to an incorrect system time zone. Adjust the time zone of your system to match your local time using the `timedatectl` command.

To set the correct time zone, use the following command:

```bash
sudo timedatectl set-timezone <your-timezone>
```

**Example**: To set the time zone to UTC:

```bash
sudo timedatectl set-timezone UTC
```

To find your correct time zone, use:

```bash
timedatectl list-timezones
```

This command will display a list of available time zones. Find your time zone and set it accordingly.

### Viewing Service State

To view the real-time state of the `simpleService` service, you can use the `journalctl` command:

```bash
sudo journalctl -u simpleService -f
```


### Viewing Server Logs

All activities of the API server are logged to `/var/log/apiServer.log`. To view the logs in real-time, use the following command:

```bash
sudo tail -f /var/log/apiServer.log
```

This will display the latest log entries as they are written, allowing you to monitor the service's operations.

### Checking Service Status and Management Commands

Here are some useful commands to manage the `apiService` service:

- **Check the Status of the Service**:

  To check whether the `apiService` service is running, use the following command:

  ```bash
  sudo systemctl status apiService.service
  ```

  This will display the current status of the service, including whether it is active, failed, or inactive, and provide recent log output.

- **Reload the Systemd Daemon**:

  If you've made any changes to the systemd service file, you need to reload the systemd daemon to apply those changes:

  ```bash
  sudo systemctl daemon-reload
  ```

  This command reloads the systemd manager configuration and applies any changes to the service files.

- **Restart the Service**:

  If you need to restart the `apiService` service for any reason (e.g., after editing the service file or script), use the following command:

  ```bash
  sudo systemctl restart apiService.service
  ```

  This will stop the service (if running) and start it again with any new configurations.

- **Stop and Disable the Service**:

  To stop and disable the service, use:

  ```bash
  sudo systemctl stop apiService.service
  sudo systemctl disable apiService.service
  ```

--- 

Feel free to reach out for any support or questions regarding the usage and setup of this service.
