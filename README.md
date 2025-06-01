# Debian Docker Image

A robust, minimal, and flexible Debian-based image with build-time hooks, optimized for modern DevOps workflows.

---

## » Overview

This project provides a **Debian stable-slim** image pre-configured with essential utilities and support for build-time hooks.  
Designed for containerized environments, it enables seamless customization and extension through hook scripts.

- **Base Image:** Debian stable-slim
- **Non-root User:** `nonroot` (for enhanced container security)
- **Tags:** Flexible tags with different package sets

---

## » Available Tags & Packages

| Tag    | Included Packages                                  |
|--------|----------------------------------------------------|
| `none` | `tini`, `curl`, `gnupg`, `libcap2-bin`             |
| `devel`| `build-essential`, `gcc`, `g++`, `make`, `cmake`   |

---

## » Quickstart

Pull the image:
```bash
docker pull hieupth/debian:[tag]
```

Start a container with all hooks enabled:
```bash
docker run -e ENABLE_ALL_HOOKS=true hieupth/debian:[tag]
```

Run container with selective hooks (example):
```bash
docker run -e ENABLE_ROOT_HOOKS="01-packages 02-pip_install" hieupth/debian:[tag]
```

Switch to root (if needed):
```dockerfile
USER root
# Install additional packages
apt-get update && apt-get install -y your-package
```

Switch back to non-root:
```dockerfile
USER nonroot
```

---

## » Hook System

This image supports **build-time hooks** to customize the image during build phase.

- **Hook Directories:**
  ```
  /hooks.d/
    ├── root/
    │     ├── 01-packages.sh
    │     └── 02-custom-setup.sh
    └── nonroot/
          ├── 01-app-setup.sh
          └── 02-entrypoint.sh
  ```
- **Naming Convention:** `NN-description.sh` to ensure execution order.

- **Execution Flow:**
  - `hooks.sh` handles hook discovery and execution based on user context (`root` or `nonroot`).
  - Hooks are controlled via environment variables.

---

## » Environment Variables

| Variable                   | Description                                                            |
|----------------------------|------------------------------------------------------------------------|
| `ENABLE_ALL_HOOKS`         | Run **all** hooks for both `root` and `nonroot`.                       |
| `ENABLE_ALL_ROOT_HOOKS`    | Run **all** root hooks.                                                |
| `ENABLE_ALL_NONROOT_HOOKS` | Run **all** nonroot hooks.                                             |
| `ENABLE_ROOT_HOOKS`        | Space-separated list of root hook script names (without `.sh`).        |
| `ENABLE_NONROOT_HOOKS`     | Space-separated list of nonroot hook script names (without `.sh`).     |
| `DEBIAN_PACKAGES`          | Space-separated list of Debian packages to install.                    |
| `HOOKS_DIR`                | Directory containing hook scripts (default: `/hooks.d`).               |

---

## » Best Practices

✅ Use the non-root user (`nonroot`) for app runtime to enhance container security.  
✅ Keep hook scripts **idempotent** to ensure safe repeated builds.  
✅ Modularize each hook script for maintainability and reusability.  
✅ Adopt semantic versioning for tags to ensure consistent CI/CD processes.  
✅ Document any non-default configurations for easy onboarding.

---

## » Contributing

Contributions are welcome! Please follow the coding standards:  
- Write idempotent, testable, and modular hooks.  
- Follow semantic commit conventions.  
- Ensure your changes do not break existing workflows.

---

## » License

[GNU AGPL v3.0](LICENSE)  
© 2025 [Hieu Pham](https://github.com/hieupth). All rights reserved.

---
