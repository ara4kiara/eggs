#!/bin/bash

# Update git jika setting auto update aktif
if [[ -d .git ]] && [[ ${AUTO_UPDATE} == "1" ]]; then
    git pull
fi

# Install paket tambahan dari variable environment
if [[ ! -z ${NODE_PACKAGES} ]]; then
    npm install ${NODE_PACKAGES}
fi

# Install dependencies bot (Disini otomatis terjadi build canvas jika diperlukan)
if [ -f /home/container/package.json ]; then
    npm install
fi

# Install paket python
if [[ ! -z ${PYTHON_PACKAGES} ]]; then
    pip3 install ${PYTHON_PACKAGES}
fi

# Logic untuk menjalankan bot
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
