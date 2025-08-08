# uml-docker
uml-docker is a proof of concept (PoC) demonstrating how to compile and run the Linux kernel in User-Mode Linux (UML) so that it can run Docker — all without requiring root privileges.

## The goal:
A statically linked single-binary Linux kernel running in user mode, capable of running the Docker daemon (`dockerd`) inside the UML environment.

# Features
- Build the kernel by simply running ./build.sh. The compiled kernel binary will be available at out/linux. (no root required, so I use rootless podman)
- On first boot, the system creates an Ubuntu-based root filesystem under `$pwd/data/rootfs.img`.
- Docker is automatically installed inside the root filesystem.
- OpenSSH server runs inside UML.
- Host TCP port 5022 is forwarded to port 22 (SSH) inside the UML.
- Root user has no password set (empty password).
- SSH access allows you to run Docker commands remotely inside UML.

# Usage
1. Build the kernel:
    ```bash
    ./build.sh
    ```
2. Start UML (example):
    ```bash
    ./out/linux
    ```
3. Connect to Docker inside UML over SSH:
    >Note: Currently, 127.0.0.1 does not work for SSH connections. Use your real IP address instead.
    ```bash
    DOCKER_HOST=ssh://root@<your-ip>:5022 docker run -it alpine
    ```
# Requirements
- Linux host with User-Mode Linux support.
- Internet access to build the root filesystem.


# How is this done

tbd