FROM node:20-bullseye-slim

LABEL author="ara4kiara" maintainer="ar4kiara.vps@gmail.com"

RUN apt update
RUN apt -y install git ca-certificates curl build-essential libtool \
    && apt -y install python3 python3-pip chromium chromium-driver ffmpeg \
    && apt -y install imagemagick libwebp-dev libwebp-tools webp \
    && apt -y install libavcodec-dev libavformat-dev libavutil-dev libswscale-dev \
    && apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    && useradd -m -d /home/container container

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
