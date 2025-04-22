# Proxy Server Setup

This project sets up a custom proxy server that listens on port 80, forwarding requests to an Apache server on port 10000. The proxy server responds with either a success or error page based on client-specific calculations. This setup includes scripts and a `systemd` service for easy configuration and management on a Linux system.

## Contents

- [Description](#description)
- [How to Use](#how-to-use)
- [System Configuration](#system-configuration)
- [Service Functionality](#service-functionality)
- [Viewing Server Logs](#viewing-server-logs)
- [Checking Service Status and Management Commands](#checking-service-status-and-management-commands)
- [Making Requests to the Proxy Server](#making-requests-to-the-proxy-server)


---

### Description

The project includes:

- A configuration script (`configureSystem.sh`) to install necessary packages and set up the system.
- A systemd service (`proxyServer.service`) to start and manage the proxy server.
- A server script (`proxyServer.sh`) that handles requests and forwards them based on specific conditions.
- Two HTML files (`index.html` for success and `error.html` for error) served based on client conditions.

### How to Use

To set up and run the proxy server, follow these steps:

1. **Clone or Download the Project**: Ensure all files are in the same directory:
   - `configureSystem.sh`
   - `proxyServer.service`
   - `proxyServer.sh`
   - `index.html`
   - `error.html`

2. **Run the Configuration Script**:
   ```bash
    sudo chmod +x configureSystem.sh
    sudo ./configureSystem.sh
    ```
This script installs necessary packages, sets up firewall rules, configures Apache, and enables the systemd service.

## System Configuration
During execution, the `configureSystem.sh` script performs the following configurations:

- **Package Installation**: Installs `apache2`, `socat`, and `iptables`.
- **Apache Configuration**: Changes Apache to listen on port 10000.
- **Firewall Rules**: Allows traffic to port 10000 only from localhost.
- **HTML File Copying**: Copies `index.html` and `error.html` to `/var/www/html/`.
- **Server Script Setup**: Moves `proxyServer.sh` to `/etc/` and makes it executable.
- **Systemd Service Setup**: Copies `proxyServer.service` to `/etc/systemd/system/`, reloads the systemd daemon, and enables the service at boot.

## Service Functionality
The `proxyServer.service` manages the proxy server, which listens on port 80 and forwards requests to Apache on port 10000.

- **Server Script Behavior**:
  - **Listening Port**: The server listens on TCP port 80, using `socat`.
  - **Client-Specific Page Selection**:
    - Calculates a number based on the client’s IP address and system uptime.
    - **If the result is odd**: Serves `index.html` (success page).
    - **If the result is even**: Serves `error.html`.
  - **Automatic Restart**: The service restarts automatically (`Restart=always`) if it stops unexpectedly, ensuring continuous availability.

## Viewing Server Logs
All activities of the Apache server can be viewed in the Apache logs, typically located at:

- `/var/log/apache2/access.log`
- `/var/log/apache2/error.log`

You can view these logs in real-time with:

```bash
sudo tail -f /var/log/apache2/access.log /var/log/apache2/error.log
```

## Checking Service Status and Management Commands
Here are commands to manage the `proxyServer.service`:

- **Check Service Status**:
  ```bash
  sudo systemctl status proxyServer.service
  ```
- **Reload the Systemd Daemon**:  
  Run this command if any changes are made to `proxyServer.service`:
  ```bash
  sudo systemctl daemon-reload
  ```

- **Restart the Service**:  
  Use this command to restart the service, applying any new configurations:
  ```bash
  sudo systemctl restart proxyServer.service
  ```

- **Stop and Disable the Service**:  
  To stop the service and prevent it from starting on boot:
  ```bash
  sudo systemctl stop proxyServer.service
  sudo systemctl disable proxyServer.service
  ```

## Making Requests to the Proxy Server
You can make requests to the proxy server from both the terminal and a browser. The proxy server listens on port 80, forwarding requests to Apache running on port 10000.

### Terminal

To make a request to the proxy server in the terminal, use `curl`:

```bash
curl http://localhost:80/
```

This command sends an HTTP request to the proxy server. The server will respond with either `index.html` or `error.html` based on the client-specific conditions.

If you're accessing the server from another machine, replace `localhost` with the IP address of the machine running the proxy server:

```bash
curl http://<server_ip>:80/
```

### Browser

You can also access the proxy server from a web browser. Open a browser and enter the server's IP address or `localhost` if you're on the same machine:

```bash
http://localhost:80/
```

Or, if accessing from a different machine:

```bash
http://<server_ip>:80/
```

The server will display either the success page (`index.html`) or the error page (`error.html`) based on the calculated response conditions.
ge (`error.html`) based on the calculated response conditions.

---
Note: The memes included on `index.html` and `error.html` pages are intended solely for entertainment purposes. They are meant to bring a bit of humor to your experience. Please view them with a sense of fun and enjoyment!
