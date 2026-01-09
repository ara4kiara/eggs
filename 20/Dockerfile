FROM node:20-bookworm-slim

LABEL author="ara4kiara" maintainer="ar4kiara.vps@gmail.com"

# Semua jadi satu layer biar tetap slim
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    \
    # tools dasar
    git ca-certificates curl build-essential libtool \
    zip unzip imagemagick ffmpeg \
    python3 python3-pip \
    \
    # chromium + driver
    chromium chromium-driver \
    \
    # dbus (buat ngurangin error "failed to connect to bus")
    dbus dbus-user-session \
    \
    # chromium runtime deps yang sering dibutuhin di Debian slim
    libnss3 libnspr4 \
    libatk-bridge2.0-0 libatk1.0-0 \
    libgtk-3-0 \
    libgbm1 libdrm2 libxshmfence1 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    libasound2 \
    \
    # fonts biar render pdf/screenshot gak aneh
    fonts-liberation fonts-noto-color-emoji \
    \
    # deps image processing (tetap dari punyamu)
    pkg-config libcairo2-dev libpango1.0-dev libfontconfig1-dev libjpeg-dev libgif-dev librsvg2-dev \
    libvips-dev libglib2.0-dev \
    libwebp-dev libavformat-dev libavcodec-dev libavutil-dev \
    libswresample-dev libswscale-dev libavfilter-dev \
    cmake \
    \
    # --- optional GUI stack for headful chromium via noVNC (Pterodactyl) ---
    xvfb fluxbox x11vnc novnc websockify \
    && \
    \
    # user container
    useradd -m -d /home/container container \
    && \
    \
    # bersihin cache biar slim (FIX: jangan apt-get purge tanpa target)
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/cache/apt/*

# pip biar bisa install tanpa drama di debian
RUN printf "[global]\nbreak-system-packages = true\n" > /etc/pip.conf

RUN npm install --omit=dev -g pm2@latest --unsafe-perm

COPY --chmod=+x ./entrypoint.sh /entrypoint.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

RUN python3 -m pip install --no-cache-dir --upgrade pip virtualenv

CMD [ "/bin/bash", "/entrypoint.sh" ]
