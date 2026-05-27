#!/usr/bin/env bash
# Module : slack
# Installe Slack depuis le .deb officiel (téléchargement de la dernière version)

set -euo pipefail

if command -v slack &>/dev/null; then
  log_warn "Slack déjà installé : $(slack --version 2>/dev/null || echo 'version inconnue')"
  exit 0
fi

log_info "Récupération de la dernière version de Slack..."

# La page de download redirige vers le dernier .deb
SLACK_URL="https://slack.com/downloads/instructions/ubuntu"
TMP_DEB="$(mktemp /tmp/slack-XXXXXX.deb)"

# Slack publie l'URL directe sous cette forme (mise à jour régulière)
# On passe par leur endpoint de redirect
DIRECT_URL="https://slack.com/ssb/download-linux-x64-deb"

log_info "Téléchargement de Slack..."
curl -fsSL -o "$TMP_DEB" "$DIRECT_URL"

log_info "Installation du .deb..."
sudo apt-get install -y "$TMP_DEB"
rm -f "$TMP_DEB"

log_ok "Slack installé."
