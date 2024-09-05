# Stage: build
FROM ghcr.io/vanilla-os/desktop:main AS build
LABEL maintainer='guztaver'
ARG DEBIAN_FRONTEND=noninteractive
ADD includes.container /
ADD sources /sources
RUN lpkg --unlock && apt-get update
RUN mkdir -p --mode=0755 /usr/share/keyrings && curl -fsSL https://pkgs.tailscale.com/stable/debian/sid.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && curl -fsSL https://pkgs.tailscale.com/stable/debian/sid.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && apt-get update && apt-get install -y tailscale
RUN apt-get install neovim emacs kitty fish rust && apt-get install git && cargo install kanata && git clone https://codeberg.org/guztaver/dotfiles /tmp/ && mkdir /usr/local/configs -p && mv /tmp/dotfiles/.config/kanata/* /usr/local/configs && mv /tmp/dotfiles/.config/* $HOME/.config && mv /tmp/dotfiles/.emacs.d $HOME && rm /tmp/dotfiles*;
RUN apt-get autoremove -y && apt-get clean && lpkg --lock
RUN rm -rf /tmp/* && rm -rf /var/tmp/* && rm -rf /sources
