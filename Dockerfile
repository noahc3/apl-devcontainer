FROM ubuntu:24.04

# Accept build arguments for user ID mapping
ARG USER_UID=1000
ARG USER_GID=1000

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    GIN_PATH=/gin \
    PATH="/gin/bin:${PATH}"

# Unminimize the Ubuntu image to restore full functionality
RUN yes | unminimize

# Update packages and install build dependencies
RUN apt update && apt install -y \
    nano \
    tree \
    unzip \
    wget \
    git \
    build-essential \
    ca-certificates \
    sudo \
    mingw-w64 \
    mingw-w64-tools \
    dotnet-sdk-8.0 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# Clone gin repository
RUN git clone https://github.com/noahc3/gin.git "$GIN_PATH" \
    && chown -R root:root "$GIN_PATH"

# Prepare gin - initialize and link metadata
RUN "$GIN_PATH/bin/gincfg" init \
    && "$GIN_PATH/bin/gincfg" meta link \
    && "$GIN_PATH/bin/gincfg" meta link-extra

# Install Wine runner and set as default
RUN "$GIN_PATH/bin/gincfg" runner install --set ElementalWarriorWine-7.9-amd64-wow64 \
    https://github.com/seapear/AffinityOnLinux/releases/download/Legacy/ElementalWarriorWine-x86_64.tar.gz

# Set up mingw32 build environment with Wine headers
RUN mkdir -p /tmp/wine-setup && cd /tmp/wine-setup \
    && cp "$GIN_PATH/runners/ElementalWarriorWine-7.9-amd64-wow64/include/wine/windows/metahost.h" \
       "/usr/x86_64-w64-mingw32/include/" \
    && cp "$GIN_PATH/runners/ElementalWarriorWine-7.9-amd64-wow64/lib/wine/x86_64-windows/mscoree.dll" \
       "./mscoree.dll" \
    && gendef mscoree.dll \
    && x86_64-w64-mingw32-dlltool -d mscoree.def -D ./mscoree.dll -l libmscoree.a \
    && cp libmscoree.a /usr/x86_64-w64-mingw32/lib/ \
    && cd / && rm -rf /tmp/wine-setup

# Configure the ubuntu user with matching UID/GID
# Ubuntu 24.04 comes with an 'ubuntu' user (UID 1000, GID 1000)
# We'll modify it to match the host user's UID/GID
RUN usermod -u ${USER_UID} ubuntu 2>/dev/null || true \
    && groupmod -g ${USER_GID} ubuntu 2>/dev/null || true \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chown -R ${USER_UID}:${USER_GID} /home/ubuntu

# Set ownership of key directories to the ubuntu user
RUN chown -R ${USER_UID}:${USER_GID} /gin

# Switch to non-root user
USER ubuntu

# Set working directory to ubuntu's home
WORKDIR /home/ubuntu

# Keep container running
CMD ["tail", "-f", "/dev/null"]
