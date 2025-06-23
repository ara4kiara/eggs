FROM node:22-bullseye-slim

LABEL author="ara4kiara" maintainer="ar4kiara.vps@gmail.com"

RUN apt update
RUN apt -y install git ca-certificates curl build-essential libtool ffmpeg \
    && apt -y install python3 python3-pip chromium chromium-driver pkg-config libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
    && apt-get update && apt-get install -y libvips libvips-dev libglib2.0-dev \
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

ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1

CMD [ "/bin/bash", "/entrypoint.sh" ] 
