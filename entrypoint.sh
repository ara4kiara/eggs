#!/bin/bash

# Update and install dependencies if needed
if [[ -d .git ]] && [[ ${AUTO_UPDATE} == "1" ]]; then
    git pull
fi

# Install additional packages if specified
if [[ ! -z ${NODE_PACKAGES} ]]; then
    npm install ${NODE_PACKAGES}
fi

# Install dependencies from package.json if it exists
if [ -f /home/container/package.json ]; then
    npm install
fi

# Install Python packages
if [[ ! -z ${PYTHON_PACKAGES} ]]; then
    pip3 install ${PYTHON_PACKAGES}
fi

# Start the application
if [[ ${CMD_RUN} == "bash" ]]; then
    echo -e "\n\e[1;34m========================================="
    echo -e "\e[1;32m        Konsol Bash Aktif 🚀\e[0m"
    echo -e "\e[1;34m========================================="
    echo -e "\e[1;36mCreated by: ar4kiara | Pterodactyl Panel\e[0m"
    echo -e "\e[1;34m-----------------------------------------\e[0m"
    echo -e "\e[1;33mSilakan masukkan perintah Anda...\e[0m\n"
    exec bash
elif [[ ${CMD_RUN} =~ ^npm ]]; then
    exec ${CMD_RUN}
elif [[ ${CMD_RUN} =~ ^yarn ]]; then
    exec ${CMD_RUN}
else
    if [ ! -f /home/container/${CMD_RUN} ]; then
        echo "Error: File ${CMD_RUN} not found"
        exit 1
    fi
    pm2 start ${CMD_RUN} && pm2 save
    exec pm2 logs
fi
