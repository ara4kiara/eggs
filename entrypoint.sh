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
    # Install with ignore-scripts to skip native module compilation during install
    # We'll rebuild canvas manually afterwards
    echo "Installing dependencies (skipping native module scripts to avoid isolated-vm errors)..."
    npm install --ignore-scripts 2>&1 | grep -v "isolated-vm" | tail -20 || {
        echo "npm install completed (isolated-vm errors are expected on Node.js v24)"
    }
    
    # Rebuild ONLY canvas (skip isolated-vm and other incompatible modules)
    # This is especially important for Node.js v24 compatibility
    echo "Rebuilding canvas native module for Node.js v24 compatibility..."
    
    # Rebuild canvas directly using node-gyp (skip isolated-vm completely)
    # npm rebuild tries to rebuild ALL native modules including isolated-vm (incompatible with Node.js v24)
    if [ -d /home/container/node_modules/canvas ]; then
        echo "Rebuilding canvas using node-gyp (skipping isolated-vm)..."
        cd /home/container/node_modules/canvas
        # Use node-gyp directly to rebuild only canvas
        node-gyp rebuild 2>&1 | grep -E "(canvas|gyp|success|error|Warning)" | tail -15 || {
            echo "Canvas rebuild completed (isolated-vm errors are expected on Node.js v24)"
        }
        cd /home/container
    fi
    
    # Rebuild canvas in canvafy if it exists
    if [ -d /home/container/node_modules/canvafy/node_modules/canvas ]; then
        echo "Rebuilding canvas in canvafy using node-gyp..."
        cd /home/container/node_modules/canvafy/node_modules/canvas
        node-gyp rebuild 2>&1 | grep -E "(canvas|gyp|success|error|Warning)" | tail -15 || {
            echo "Canvafy canvas rebuild completed (isolated-vm errors are expected on Node.js v24)"
        }
        cd /home/container
    fi
    
    echo "Canvas rebuild completed (isolated-vm errors ignored - not compatible with Node.js v24)."
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
