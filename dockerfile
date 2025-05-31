# ------------------------------------------
# Dockerfile
# ------------------------------------------
# Base: Debian stable-slim
# Purpose:
#   - Copy and run hook scripts as root (if enabled).
#   - Install required packages via DEBIAN_PACKAGES (if enabled).
#   - Create non-root user for runtime.
#   - Configure tini as entrypoint for signal handling.
# Environment Variables:
#   - ENTRYPOINT: main entrypoint script
#   - HOOK: hook runner script
#   - ENABLE_HOOK: enable/disable hooks
#   - ENABLE_DEBIAN_PACKAGES: enable/disable package installation
#   - DEBIAN_PACKAGES: packages to install
# ------------------------------------------

ARG BASE_IMAGE=debian:stable-slim

FROM ${BASE_IMAGE} AS build

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Define ARGs and set corresponding ENVs
ARG ENTRYPOINT=/usr/local/bin/entrypoint.sh
ENV ENTRYPOINT=${ENTRYPOINT:-/usr/local/bin/entrypoint.sh}

ARG HOOK_SCRIPT=/usr/local/bin/hooks.sh
ENV HOOK_SCRIPT=${HOOK_SCRIPT:-/usr/local/bin/hooks.sh}

ARG ENABLE_ALL_HOOKS=true
ENV ENABLE_ALL_HOOKS=${ENABLE_ALL_HOOKS:-false}

ARG PACKAGES="tini curl libcap2-bin ca-certificates"
ENV PACKAGES=${PACKAGES:-}

# Copy scripts and hooks
COPY hooks.d /hooks.d
COPY hooks.sh ${HOOK_SCRIPT}
COPY entrypoint.sh ${ENTRYPOINT}

# Execute entrypoint (which may run hooks during build)
RUN chmod +x ${ENTRYPOINT} && chmod +x ${HOOK_SCRIPT}
RUN /bin/bash "${HOOK_SCRIPT}"

# Create non-root user for runtime
RUN useradd -m nonroot
USER nonroot
WORKDIR /home/nonroot

# Use tini as entrypoint with non-root user
ENTRYPOINT [ "tini", "--", "${ENTRYPOINT}" ]
CMD []