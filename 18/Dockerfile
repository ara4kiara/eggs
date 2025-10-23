FROM node:18-bookworm-slim [cite: 3]

LABEL author="ara4kiara" maintainer="ar4kiara.vps@gmail.com"

# Menggabungkan apt update, install, dan clean up. Menambahkan dependensi canvas & sharp
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates curl build-essential libtool ffmpeg zip unzip imagemagick \
    python3 python3-pip chromium chromium-driver \
    # Dependensi untuk node-canvas
    pkg-config libcairo2-dev libpango1.0-dev libfontconfig1-dev libjpeg-dev libgif-dev librsvg2-dev \
    # Dependensi untuk sharp (libvips)
    libvips-dev libglib2.0-dev \
    && useradd -m -d /home/container container \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN printf "[global]\nbreak-system-packages = true\n" > /etc/pip.conf 

# Install PM2 globally as root
RUN npm install -g pm2@latest --unsafe-perm 

# Copy entrypoint.sh and give execute permissions as root
COPY ./entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh 

USER container [cite: 3]
ENV USER=container HOME=/home/container [cite: 3]
WORKDIR /home/container 

# Install Python packages
RUN pip3 install --upgrade pip setuptools wheel 

CMD [ "/bin/bash", "/entrypoint.sh" ]
