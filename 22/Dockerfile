FROM node:22-bullseye-slim

LABEL author="ara4kiara" maintainer="ar4kiara.vps@gmail.com"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git ca-certificates curl build-essential libtool \
    python3 python3-pip chromium chromium-driver pkg-config libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev ffmpeg \
    imagemagick libwebp-dev libwebp-tools \
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev \
    libgstreamer1.0-dev gstreamer1.0-plugins-base \
    && useradd -m -d /home/container container \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PM2 globally as root
RUN npm install -g pm2@latest --unsafe-perm

# Copy entrypoint.sh and give execute permissions as root
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Install Python packages
RUN pip3 install --upgrade pip setuptools wheel

CMD [ "/bin/bash", "/entrypoint.sh" ] 
