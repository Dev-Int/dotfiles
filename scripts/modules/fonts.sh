#!/usr/bin/env bash
# Module : fonts
# Installe les fonts nécessaires au terminal et au thème zsh agnoster

set -euo pipefail

# ─── PowerlineSymbols (requis pour le thème agnoster) ─────────────────────────
if ! fc-list | grep -qi "PowerlineSymbols"; then
  log_info "Installation de fonts-powerline..."
  sudo apt-get install -y fonts-powerline
  log_ok "fonts-powerline installé."
else
  log_warn "PowerlineSymbols déjà installée."
fi

# ─── Ubuntu Mono (font Terminator) ────────────────────────────────────────────
if ! fc-list | grep -qi "Ubuntu Mono"; then
  log_info "Installation de fonts-ubuntu..."
  sudo apt-get install -y fonts-ubuntu
  log_ok "fonts-ubuntu installé."
else
  log_warn "Ubuntu Mono déjà installée."
fi

log_info "Rafraîchissement du cache de fonts..."
fc-cache -f
log_ok "Cache fonts mis à jour."