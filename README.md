# Linux Service Bundle

A modular collection of **four plug-and-play Linux system services** using `bash`, `socat`, `iptables`, and `systemd`. Ideal for learning, rapid deployment, or DevOps-style automation. Each module is self-contained and configurable via a script.

## Included Services

| Service                      | Description                                                                            |
|------------------------------|----------------------------------------------------------------------------------------|
| `simple-service`             | Periodically logs system time and ARP cache via a `systemd` timer.                     |
| `api-service`                | A simple TCP API server using `socat`, with query support for capitals and currencies. |
| `proxy-server-service`       | A proxy server that routes to Apache with dynamic logic for success/error pages.       |
| `ftp-auth-service`           | FTP server with dynamic IP-based access using `vsftpd`, `iptables`, and authentication.|

Each service includes:
- Setup script for packages, folders, and permissions
- `systemd` unit for lifecycle management
- Logging and monitoring instructions
- Optional configuration tweaks

## How to Use

1. Clone this repository:
   ```bash
   git clone https://github.com/iravelmakina/systemd-automation-pack.git
   cd linux-service-bundle
   ```

2. Choose a service:
   ```bash
   cd simple-service
   ./configure_system.sh
   ```

3. Repeat for any other module you'd like to use.

## Requirements

- Linux system (Debian/Ubuntu recommended)
- `bash`, `systemd`, `socat`, `iptables`, `vsftpd` (installed per script)
- Root privileges (`sudo`)

## Individual Service Guides

See each folder for a dedicated `README.md`:
- [`simple-service`](./simple-service/)
- [`api-service`](./api-service/)
- [`proxy-server-service`](./proxy-server-service/)
- [`ftp-auth-service`](./ftp-auth-service/)

---

## Contributing

Pull requests are welcome! Feel free to suggest improvements, features, or bug fixes.

## License

This project is open-source under the **MIT License**.
