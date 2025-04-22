# FTP Server and Authentication Setup

This project configures an FTP server with dynamic IP-based access control managed via `iptables`. It includes a custom authentication server (`authServer.sh`) to validate access based on client-provided credentials. The solution integrates `vsftpd` for FTP services and uses `socat` for the authentication server, ensuring secure and dynamic control of FTP access.

## Contents

- [Description](#description)
- [Installation](#installation)
- [How to Use](#how-to-use)
- [System Configuration](#system-configuration)
- [Service Functionality](#service-functionality)
- [Managing Services and Logs](#managing-services-and-logs)
- [Testing the Setup](#testing-the-setup)
- [Using the FTP Server](#using-the-ftp-server)

---

### Description

The project includes:

- A configuration script (`configureServer.sh`) to:
  - Install necessary packages.
  - Configure `vsftpd` for FTP services.
  - Set up static IP-based access rules.
  - Install and configure the custom authentication server.
- An authentication server (`authServer.sh`) to dynamically allow or deny FTP access based on credentials.
- A `systemd` service (`authServer.service`) to manage the authentication server.
- A credentials file (`credentials.txt`) for IP and authorization key mapping.

---

### Installation

1. **Clone or Download the Project**:
   Ensure all the following files are in the same directory:
   - `configureServer.sh`
   - `authServer.sh`
   - `authServer.service`
   - `credentials.txt`

2. **Run the Configuration Script**:
   - Make the script executable:
     ```bash
     sudo chmod +x configureServer.sh
     ```
   - Execute the script:
     ```bash
     sudo ./configureServer.sh <comma-separated-IP-list>
     ```
   - Replace `<comma-separated-IP-list>` with static IPs that should always have FTP access.
   - If no static IPs are required, leave the input empty.

3. **Verify Installation**:
   - Check the status of the `authServer.service`:
     ```bash
     sudo systemctl status authServer.service
     ```
   - Ensure `vsftpd` is running:
     ```bash
     sudo systemctl status vsftpd
     ```

---

### How to Use

1. **Set Up Static IP Access**:
   - During installation, provide a list of comma-separated static IPs that should have permanent FTP access (list is optional and can be missing if not needed).
   - Example:
     ```bash
     sudo ./configureServer.sh 192.168.64.18,192.168.64.19
     ```

2. **Dynamic IP Authentication**:
   - Clients without static access must authenticate via the `authServer.sh` script by connecting to port `7777`:
     ```bash
     nc <server_ip> 7777
     ```
   - Enter the authorization key when prompted. If the key matches, access is granted.

---

### System Configuration

During execution, the `configureServer.sh` script performs the following configurations:

1. **Package Installation**: Installs `vsftpd`, `iptables`, and `socat`.
2. **ICMP Blocking**: Disables ping requests via `iptables`.
3. **FTP Server Setup**:
   - Configures `vsftpd` with a new user `ftp_user` (password: `MyFTPPass!`).
   - Creates `1.txt` and `2.txt` in `/home/ftp_user/`.
   - Restarts the `vsftpd` service.
4. **Static IP Access**: Adds static IPs (if provided) to `iptables` rules, with other access denied by default.
5. **Dynamic Authentication Server**:
   - Installs `authServer.sh` to `/usr/bin/`.
   - Copies `credentials.txt` to `/etc/authServer/`.
   - Sets up the `authServer.service` to listen on port `7777` for authentication requests.

---

### Service Functionality

1. **FTP Server (`vsftpd`)**:
   - Listens on port `21`.
   - Allows access to authenticated IPs only.

2. **Authentication Server (`authServer.service`)**:
   - Listens on port `7777` via `socat`.
   - Validates client IP and authorization key against `credentials.txt`.
   - Dynamically updates `iptables` rules to grant or deny FTP access.

3. **Dynamic Access Control**:
   - Valid credentials: Grants FTP access to the client IP.
   - Invalid credentials: Denies FTP access to the client IP.

---

### Managing Services and Logs

#### Managing `authServer.service`

- **Restart the Service**:
  ```bash
  sudo systemctl restart authServer.service
  ```

- **Stop and Disable the Service**:
  ```bash
  sudo systemctl stop authServer.service
  sudo systemctl disable authServer.service
  ```

#### FTP Logs

- Logs for `vsftpd` can be found in:
  - `/var/log/vsftpd.log`
  - `/var/log/xferlog`

- View logs in real-time:
  ```bash
  sudo tail -f /var/log/vsftpd.log /var/log/xferlog
  ```

---

### Testing the Setup

1. **Verify Static IP Access**:
   - Use an FTP client or `curl` to connect to the server from a static IP:
     ```bash
     ftp <server_ip>
     ```
     ```bash
     curl -u ftp_user:MyFTPPass! ftp://<server_ip>/
     ```
   - Use `ftp_user` as the username and `MyFTPPass!` as the password.

2. **Dynamic IP Authentication**:
   - Connect to the authentication server on port `7777`:
     ```bash
     nc <server_ip> 7777
     ```
   - Provide a valid authorization key when prompted.

3. **Check Access**:
   - On successful authentication, FTP access is granted.
   - For denied access, check `iptables` rules:
     ```bash
     sudo iptables -L -n
     ```
  - Terminate your session using `Ctrl + C`

---

### Using the FTP Server

1. **Connect to the FTP Server**:
   - Use an FTP client, terminal, or browser to connect to the server on port `21`:
     ```bash
     ftp <server_ip>
     ```
   - Replace `<server_ip>` with the actual IP address of the server.

2. **Login Credentials**:
   - Username: `ftp_user`
   - Password: `MyFTPPass!`

3. **Browse and Download Files**:
   - Once logged in, use FTP commands to navigate and download files:
     ```
     ftp> ls
     ftp> get 1.txt
     ftp> get 2.txt
     ```

4. **Exit the FTP Session**:
   - To logout, use the `Ctrl + C`, `bye`, `exit`, or `quit` command:
     ```
     ftp> quit
     ```

---

Feel free to reach out for any support or questions regarding the usage and setup of this service.

---
