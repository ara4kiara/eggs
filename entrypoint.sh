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
    # Rebuild native modules (canvas, canvafy, etc.) after install
    # This is especially important for Node.js v24 compatibility
    echo "Checking for native modules that need rebuilding..."
    
    # Rebuild canvas if it exists
    if [ -d /home/container/node_modules/canvas ]; then
        echo "Rebuilding canvas native module for Node.js compatibility..."
        npm rebuild canvas --build-from-source 2>&1 | head -20 || echo "Canvas rebuild failed, continuing anyway..."
    fi
    
    # Rebuild canvafy dependencies (canvas is a dependency of canvafy)
    if [ -d /home/container/node_modules/canvafy ]; then
        echo "Rebuilding canvafy dependencies..."
        # Rebuild canvas first if it's a dependency
        if [ -d /home/container/node_modules/canvafy/node_modules/canvas ]; then
            cd /home/container/node_modules/canvafy/node_modules/canvas
            npm rebuild --build-from-source 2>&1 | head -20 || echo "Canvafy canvas rebuild failed, continuing anyway..."
            cd /home/container
        fi
        npm rebuild canvafy --build-from-source 2>&1 | head -20 || echo "Canvafy rebuild failed, continuing anyway..."
    fi
    
    echo "Native module rebuild check completed."
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
elif [[ ${CMD_RUN} =~ ^node ]]; then
    exec ${CMD_RUN}
else
    # Cek jika CMD_RUN mengandung spasi (ada argumen)
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
