#!/bin/bash
set -e

# --- Fix runtime env untuk Chromium (dbus + tmp) ---
export HOME=${HOME:-/home/container}
export USER=${USER:-container}

# Pastikan tmp & run ada dan bisa ditulis (penting di pterodactyl)
mkdir -p /tmp /run/dbus || true

# Coba set permission. Kalau gak bisa (karena filesystem/perm), lanjut aja.
chmod 1777 /tmp 2>/dev/null || true
chmod 755 /run /run/dbus 2>/dev/null || true

# Start dbus-daemon kalau ada (biar chromium gak rewel soal bus)
if command -v dbus-daemon >/dev/null 2>&1; then
  # Buat socket system bus (dbus-daemon akan create socket di /run/dbus/)
  dbus-daemon --system --fork 2>/dev/null || true

  # Bantu beberapa library yang nyari alamat bus
  if [ -S /run/dbus/system_bus_socket ]; then
    export DBUS_SYSTEM_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"
  fi
fi

# Set path chromium untuk puppeteer/playwright yang butuh
if command -v chromium >/dev/null 2>&1; then
  export CHROME_BIN="$(command -v chromium)"
elif command -v chromium-browser >/dev/null 2>&1; then
  export CHROME_BIN="$(command -v chromium-browser)"
fi

# --- Optional: Headful display via Xvfb + noVNC (ENABLE_VNC=1) ---
# Tujuan: kamu bisa buka noVNC di browser dan solve Turnstile secara manual.
# Tanpa ENABLE_VNC=1, script berjalan normal seperti sebelumnya.
if [[ "${ENABLE_VNC}" == "1" ]]; then
  export DISPLAY=${DISPLAY:-:99}
  export XDG_RUNTIME_DIR=/tmp/runtime-container
  mkdir -p "$XDG_RUNTIME_DIR" || true
  chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true

  # Start virtual X server
  if command -v Xvfb >/dev/null 2>&1; then
    Xvfb ${DISPLAY} -screen 0 1280x720x24 -ac +extension GLX +render -noreset >/dev/null 2>&1 &
    sleep 1
  fi

  # Lightweight window manager
  if command -v fluxbox >/dev/null 2>&1; then
    fluxbox >/dev/null 2>&1 &
    sleep 1
  fi

  # VNC server
  if command -v x11vnc >/dev/null 2>&1; then
    x11vnc -display ${DISPLAY} -forever -shared -nopw -rfbport 5900 -listen 0.0.0.0 >/dev/null 2>&1 &
    sleep 1
  fi

  # noVNC on 6080 (web UI)
  if command -v websockify >/dev/null 2>&1; then
    websockify --web=/usr/share/novnc/ 0.0.0.0:6080 0.0.0.0:5900 >/dev/null 2>&1 &
    sleep 1
  fi

  echo "[ENTRYPOINT] noVNC enabled on port 6080 (ENABLE_VNC=1)"
fi

# --- Update git jika setting auto update aktif ---
if [[ -d .git ]] && [[ ${AUTO_UPDATE} == "1" ]]; then
    git pull
fi

# --- Install paket tambahan dari variable environment ---
if [[ ! -z ${NODE_PACKAGES} ]]; then
    npm install ${NODE_PACKAGES}
fi

# --- Install dependencies bot (otomatis build canvas jika diperlukan) ---
if [ -f /home/container/package.json ]; then
    npm install
fi

# --- Install paket python ---
if [[ ! -z ${PYTHON_PACKAGES} ]]; then
    pip3 install ${PYTHON_PACKAGES}
fi

# --- Logic untuk menjalankan bot ---
if [[ ${CMD_RUN} == "bash" ]]; then
    echo -e "\n\e[1;34m========================================="
    echo -e "\e[1;32m        Konsol Bash Aktif 🚀\e[0m"
    echo -e "\e[1;34m========================================="
    exec bash
elif [[ ${CMD_RUN} =~ ^npm ]]; then
    exec ${CMD_RUN}
elif [[ ${CMD_RUN} =~ ^yarn ]]; then
    exec ${CMD_RUN}
elif [[ ${CMD_RUN} =~ ^node ]]; then
    exec ${CMD_RUN}
else
    # Logic PM2
    if [[ "${CMD_RUN}" == *" "* ]]; then
        FILE=$(echo ${CMD_RUN} | awk '{print $1}')
        ARGS=$(echo ${CMD_RUN} | cut -d' ' -f2-)
        if [ ! -f /home/container/${FILE} ]; then
            echo "Error: File ${FILE} not found"
            exit 1
        fi
        pm2 start ${FILE} --name ${FILE%%.*} -- ${ARGS}
        pm2 save
        exec pm2 logs
    else
        if [ ! -f /home/container/${CMD_RUN} ]; then
            echo "Error: File ${CMD_RUN} not found"
            exit 1
        fi
        pm2 start ${CMD_RUN}
        pm2 save
        exec pm2 logs
    fi
fi
