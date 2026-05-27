#!/usr/bin/env bash
# Module : git
# Déploie la config git selon le profil machine

set -euo pipefail

PROFILE="${MACHINE_PROFILE:-perso}"
GIT_DIR="$DOTFILES_DIR/git"

if ! command -v git &>/dev/null; then
  log_info "Installation de git..."
  sudo apt-get install -y git git-lfs
fi

# ─── .gitconfig selon profil ──────────────────────────────────────────────────
GITCONFIG_SRC="$GIT_DIR/.gitconfig.$PROFILE"
if [ -f "$GITCONFIG_SRC" ]; then
  if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$(date +%Y%m%d%H%M%S)"
    log_warn ".gitconfig existant sauvegardé."
  fi
  ln -sf "$GITCONFIG_SRC" "$HOME/.gitconfig"
  log_ok ".gitconfig → .gitconfig.$PROFILE"
else
  log_warn "Fichier absent : $GITCONFIG_SRC"
  log_warn "Crée git/.gitconfig.$PROFILE dans le repo dotfiles."
fi

# ─── .gitignore global ────────────────────────────────────────────────────────
if [ -f "$GIT_DIR/.gitignore_global" ]; then
  ln -sf "$GIT_DIR/.gitignore_global" "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"
  log_ok ".gitignore_global lié."
fi

# ─── Git LFS ──────────────────────────────────────────────────────────────────
if command -v git-lfs &>/dev/null; then
  git lfs install --skip-repo 2>/dev/null || true
  log_ok "Git LFS configuré."
fi