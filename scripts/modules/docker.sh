#!/usr/bin/env bash
# Module : docker
# Installe Docker Engine via le repo officiel Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

set -euo pipefail

if command -v docker &>/dev/null; then
  log_warn "Docker déjà installé : $(docker --version)"
  exit 0
fi

log_info "Installation de Docker Engine (repo officiel)..."

# ─── Dépendances ──────────────────────────────────────────────────────────────
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# ─── Clé GPG officielle Docker ────────────────────────────────────────────────
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
log_ok "Clé GPG Docker ajoutée."

# ─── Repo apt Docker ──────────────────────────────────────────────────────────
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
log_ok "Repo Docker ajouté."

# ─── Installation ─────────────────────────────────────────────────────────────
sudo apt-get update -qq
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
log_ok "Docker Engine installé : $(docker --version)"

# ─── Groupe docker (évite sudo à chaque commande) ─────────────────────────────
if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
  log_ok "Utilisateur '$USER' ajouté au groupe docker."
  log_warn "Déconnecte-toi et reconnecte-toi pour que le groupe soit actif."
fi