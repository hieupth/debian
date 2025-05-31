#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# hooks.sh
# ------------------------------------------------------------------------------
# Purpose:
#   Executes hook scripts based on environment variables and user privilege.
# Features:
#   - Supports running all hooks or selective hooks.
#   - Organizes hooks by user: root or nonroot.
#   - Provides clear, structured logging.
# ==============================================================================

readonly HOOKS_DIR="${HOOKS_DIR:-/hooks.d}"

# ------------------------------------------------------------------------------
# Logging function
# ------------------------------------------------------------------------------
log() {
  echo "[hooks.sh] $*"
}

# ------------------------------------------------------------------------------
# Executes a single hook script
# ------------------------------------------------------------------------------
execute_hook() {
  local script="$1"
  log "Executing hook: ${script}"
  chmod +x "${script}"
  bash "${script}"
}

# ------------------------------------------------------------------------------
# Runs all hook scripts in the given directory
# ------------------------------------------------------------------------------
run_all_hooks() {
  local dir="$1"
  find "${dir}" -type f -name "*.sh" -print0 | sort -z | while IFS= read -r -d '' script; do
    execute_hook "${script}"
  done
}

# ------------------------------------------------------------------------------
# Determines which hooks directory and environment variables apply
# ------------------------------------------------------------------------------
determine_user_context() {
  if [[ "$(id -u)" -eq 0 ]]; then
    echo "root ${HOOKS_DIR}/root ${ENABLE_ROOT_HOOKS:-} ${ENABLE_ALL_ROOT_HOOKS:-false}"
  else
    echo "nonroot ${HOOKS_DIR}/nonroot ${ENABLE_NONROOT_HOOKS:-} ${ENABLE_ALL_NONROOT_HOOKS:-false}"
  fi
}

# ------------------------------------------------------------------------------
# Main execution logic
# ------------------------------------------------------------------------------
main() {
  local user_type hooks_dir enabled_hooks enable_all_user_hooks
  read -r user_type hooks_dir enabled_hooks enable_all_user_hooks <<< "$(determine_user_context)"

  if [[ ! -d "${hooks_dir}" ]]; then
    log "No hooks directory found at ${hooks_dir}. Skipping."
    exit 0
  fi

  log "Using hooks directory: ${hooks_dir}"

  # Highest priority: Run all hooks
  if [[ "${ENABLE_ALL_HOOKS:-false}" == "true" ]]; then
    log "ENABLE_ALL_HOOKS is true. Running all root and nonroot hooks."
    run_all_hooks "${HOOKS_DIR}/root"
    run_all_hooks "${HOOKS_DIR}/nonroot"
    exit 0
  fi

  # Next priority: Run all user-specific hooks
  if [[ "${enable_all_user_hooks}" == "true" ]]; then
    log "ENABLE_ALL_${user_type^^}_HOOKS is true. Running all ${user_type} hooks."
    run_all_hooks "${hooks_dir}"
    exit 0
  fi

  # Finally: Run selected hooks
  if [[ -n "${enabled_hooks}" ]]; then
    log "Selected hooks to run: ${enabled_hooks}"
    for hook_name in ${enabled_hooks}; do
      local script_path="${hooks_dir}/${hook_name}.sh"
      if [[ -f "${script_path}" ]]; then
        execute_hook "${script_path}"
      else
        log "Hook script not found: ${script_path}. Skipping."
      fi
    done
  else
    log "No hooks specified for ${user_type}. Skipping."
  fi

  log "Hook execution completed."
}

main "$@"