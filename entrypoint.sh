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
if [[ ${CMD_RUN} =~ ^npm ]]; then
    # If it's an npm command, run it directly
    exec ${CMD_RUN}
else
    # Check if the file exists
    if [ ! -f /home/container/${CMD_RUN} ]; then
        echo "Error: File ${CMD_RUN} not found"
        exit 1
    fi
# Start with PM2
  pm2 start ${CMD_RUN} && pm2 save
  exec pm2 logs
fi
