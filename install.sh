#!/bin/bash

JENKINS_KEYFILE="$HOME/.ssh/jenkins_agent_key"
JENKINS_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINU8NgOYbxPQRNKc2qmIW0by+fMZLX13tX0QcQqkExW9 jenkins"

set -xe

function install_docker() {
    apt update
    apt install --yes ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
        | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo deb [arch=$(dpkg --print-architecture) \
            signed-by=/etc/apt/keyrings/docker.gpg] \
            https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable \
        > /etc/apt/sources.list.d/docker.list
    apt update
    apt install --yes docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

case "$1" in
    docker)
        install_docker
        ;;
    jenkins)
        install_docker
        pushd jenkins
        docker compose up -d
        if [[ ! -f "$JENKINS_KEYFILE" ]]; then
            ssh-keygen -q -t ed25519 -f "$JENKINS_KEYFILE" -N ""
        fi
        ;;
    agent)
        install_docker
        apt install --yes openjdk-11-jre-headless
        if ! grep --fixed-strings --line-regexp "$JENKINS_PUBKEY" "/root/.ssh/authorized_keys" > /dev/null; then
            echo "$JENKINS_PUBKEY" >> "/root/.ssh/authorized_keys"
        fi
        ;;
    *)
        echo "$0 docker|jenkins|agent"
        echo ""
        ;;
esac
