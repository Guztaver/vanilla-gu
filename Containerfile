# Stage: build
FROM ghcr.io/vanilla-os/desktop:main AS build
LABEL maintainer='guztaver'
ARG DEBIAN_FRONTEND=noninteractive
ADD includes.container /
ADD sources /sources
RUN lpkg --unlock && apt-get update
RUN apt-get install -y  emacs kitty fish git wget neovim  && apt-get clean
RUN mkdir -p --mode=0755 /usr/share/keyrings && curl -fsSL https://pkgs.tailscale.com/stable/debian/sid.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && curl -fsSL https://pkgs.tailscale.com/stable/debian/sid.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && apt-get update && apt-get install -y tailscale
RUN git clone https://codeberg.org/guztaver/dotfiles /tmp/dotfiles
RUN mkdir -p /usr/local/bin && mkdir -p /usr/local/configs && wget -O /usr/local/bin/kanata https://github.com/jtroo/kanata/releases/latest/download/kanata && chmod +x /usr/local/bin/kanata
RUN mv /tmp/dotfiles/.config/kanata/* /usr/local/configs
RUN IMAGE_NAME="$(cat /image-info/image-name)" && echo custom image name "$IMAGE_NAME" && IMAGE_NAME_ESCAPED="$(echo $IMAGE_NAME | sed 's/\//\\\//g')" && sed -i "s/changed_automatically_by_vib/$IMAGE_NAME_ESCAPED/g" /usr/share/abroot/abroot.json && rm -rf /image-info
RUN apt remove -y zutty gnome-shell-extension-prefs && SUDO_FORCE_REMOVE=yes apt purge -y sudo && echo 'NoDisplay=true' >> /usr/share/applications/software-properties-gtk.desktop
RUN apt-get autoremove -y && apt-get clean && lpkg --lock
RUN rm -rf /tmp/* && rm -rf /var/tmp/* && rm -rf /sources
