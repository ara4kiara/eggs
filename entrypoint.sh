    #!/bin/bash

    # Install global packages needed at runtime
    npm install -g pm2@latest

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

    # Start the application with PM2
    if [ ! -f /home/container/${CMD_RUN} ] && [[ ! ${CMD_RUN} =~ ^npm ]]; then echo "Error: File ${CMD_RUN} not found"; exit 1; fi; pm2 start ${CMD_RUN} --no-daemon
