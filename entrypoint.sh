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
