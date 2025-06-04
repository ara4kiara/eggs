FROM node:18-bullseye-slim

LABEL author="ara4kiara" maintainer="ar4kiara.vps@gmail.com"

RUN apt update
RUN apt -y install ffmpeg iproute2 git sqlite3 libsqlite3-dev ca-certificates dnsutils tzdata zip tar curl build-essential libtool iputils-ping \
    && apt -y install python3 python3-dev python3-pip chromium chromium-driver \
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
