#!/usr/bin/env bash
# Module : terminator
# Installe Terminator et déploie sa configuration

set -euo pipefail

TERMINATOR_SRC="$DOTFILES_DIR/terminal/terminator/config"
TERMINATOR_DEST="$HOME/.config/terminator/config"

# ─── Installation ─────────────────────────────────────────────────────────────
if ! command -v terminator &>/dev/null; then
  log_info "Installation de Terminator..."
  sudo apt-get install -y terminator
  log_ok "Terminator installé."
else
  log_warn "Terminator déjà installé."
fi

# ─── Config ───────────────────────────────────────────────────────────────────
if [ -f "$TERMINATOR_SRC" ]; then
  mkdir -p "$HOME/.config/terminator"

  if [ -f "$TERMINATOR_DEST" ] && [ ! -L "$TERMINATOR_DEST" ]; then
    cp "$TERMINATOR_DEST" "${TERMINATOR_DEST}.backup.$(date +%Y%m%d%H%M%S)"
    log_warn "Config Terminator existante sauvegardée."
  fi

  ln -sf "$TERMINATOR_SRC" "$TERMINATOR_DEST"
  log_ok "Config Terminator liée : $TERMINATOR_DEST"
else
  log_warn "Fichier source introuvable : $TERMINATOR_SRC"
  log_warn "Lance './scripts/capture.sh terminator' pour capturer ta config actuelle."
fi
