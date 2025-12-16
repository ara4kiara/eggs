FROM node:24-bookworm-slim

LABEL author="ara4kiara" maintainer="ar4kiara.vps@gmail.com"

# --- BAGIAN 1: INSTALL SYSTEM DEPENDENCIES (FINAL) ---
# Menggunakan daftar paket komplit dari versi 'acak-acakan' tapi dirapikan.
# 'cmake' sangat penting untuk build module di Node 24.
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    build-essential \
    libtool \
    ffmpeg \
    zip \
    unzip \
    imagemagick \
    python3 \
    python3-pip \
    chromium \
    chromium-driver \
    cmake \
    # Dependensi Canvas & Graphics (LENGKAP)
    pkg-config \
    libcairo2-dev \
    libpango1.0-dev \
    libfontconfig1-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    libpixman-1-dev \
    libpangocairo-1.0-0 \
    # Dependensi Sharp
    libvips-dev \
    libglib2.0-dev \
    && useradd -m -d /home/container container \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- BAGIAN 2: KONFIGURASI TAMBAHAN ---
RUN printf "[global]\nbreak-system-packages = true\n" > /etc/pip.conf 

# Install PM2
RUN npm install -g pm2@latest --unsafe-perm 

# Setup Entrypoint
COPY ./entrypoint.sh /entrypoint.sh 
RUN chmod +x /entrypoint.sh 

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container 

# Upgrade PIP
RUN pip3 install --upgrade pip setuptools wheel 

CMD [ "/bin/bash", "/entrypoint.sh" ]
