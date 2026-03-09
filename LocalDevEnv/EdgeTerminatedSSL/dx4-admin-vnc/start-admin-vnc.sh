#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Runs inside dx4-admin container:
#  - starts Xvfb + fluxbox
#  - starts x11vnc (TCP 5900 inside container)
#  - starts noVNC/websockify HTTP server (6080 inside container)
#  - starts Swing Admin Client
#  - starts Admin Server (existing behavior) and keeps container alive
# -------------------------------------------------------------------

DISPLAY_NUM="${DISPLAY_NUM:-:1}"
VNC_PORT="${VNC_PORT:-5900}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
GEOMETRY="${GEOMETRY:-1600x900}"
DEPTH="${DEPTH:-24}"

ADMINCLIENT_DIR="${ADMINCLIENT_DIR:-/home/doxis4/DOXiS4SoapAdminClient}"
ADMINCLIENT_CMD="${ADMINCLIENT_CMD:-./DOXiS4CSBAdminClient}"

# Original admin server start command from image metadata
ADMINSERVER_CMD="bash -lc \"${DX4_ENTRYPOINT} ${DX4_ADMINSERVER_HOME_DIR}/DOXiS4CSBAdminServer\""

export DISPLAY="${DISPLAY_NUM}"

log() { echo "[$(date -Is)] $*"; }

# Track children so we can stop cleanly
pids=()
cleanup() {
  log "Shutting down..."
  for pid in "${pids[@]:-}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
  # Give processes a moment
  sleep 1
  for pid in "${pids[@]:-}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
    fi
  done
}
trap cleanup INT TERM

log "Starting Xvfb on ${DISPLAY} (${GEOMETRY}x${DEPTH})"
Xvfb "${DISPLAY}" -screen 0 "${GEOMETRY}x${DEPTH}" -ac +extension GLX +render -noreset &
pids+=("$!")

log "Starting fluxbox"
fluxbox >/tmp/fluxbox.log 2>&1 &
pids+=("$!")

# VNC password (recommended). If VNC_PASSWORD is unset, run without password.
VNC_AUTH_ARGS=("-nopw")
if [[ -n "${VNC_PASSWORD:-}" ]]; then
  mkdir -p /home/doxis4/.vnc
  x11vnc -storepasswd "${VNC_PASSWORD}" /home/doxis4/.vnc/passwd >/dev/null 2>&1 || true
  VNC_AUTH_ARGS=("-rfbauth" "/home/doxis4/.vnc/passwd")
fi

log "Starting x11vnc on :${VNC_PORT}"
# -forever keeps serving, -shared allows multiple viewers
x11vnc -display "${DISPLAY}" -rfbport "${VNC_PORT}" \
  -forever -shared -repeat -ncache 10 \
  "${VNC_AUTH_ARGS[@]}" \
  >/tmp/x11vnc.log 2>&1 &
pids+=("$!")

log "Starting noVNC/websockify on :${NOVNC_PORT} (to localhost:${VNC_PORT})"
# websockify serves both the websocket endpoint (/websockify) and static noVNC UI.
# Ubuntu/Debian package location: /usr/share/novnc
websockify --web=/usr/share/novnc/ "${NOVNC_PORT}" "localhost:${VNC_PORT}" \
  >/tmp/websockify.log 2>&1 &
pids+=("$!")

log "Starting Swing Admin Client (${ADMINCLIENT_DIR}/${ADMINCLIENT_CMD})"
(
  cd "${ADMINCLIENT_DIR}"
  exec ${ADMINCLIENT_CMD}
) >/tmp/adminclient.log 2>&1 &
pids+=("$!")

log "Starting Admin Server (existing dx4-admin behavior)"
set +e
bash -lc "${DX4_ENTRYPOINT} ${DX4_ADMINSERVER_HOME_DIR}/DOXiS4CSBAdminServer" &
ADM_PID=$!
set -e
pids+=("${ADM_PID}")

# Wait for admin server to exit (treat as main service)
wait "${ADM_PID}"
exit_code=$?
log "Admin Server exited with code ${exit_code}"
exit "${exit_code}"
