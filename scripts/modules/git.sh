#!/usr/bin/env bash
# Module : git
# Déploie la config git globale et le gitignore global

set -euo pipefail

GIT_DIR="$DOTFILES_DIR/git"

if ! command -v git &>/dev/null; then
  log_info "Installation de git..."
  sudo apt-get install -y git
fi

# ─── .gitconfig ───────────────────────────────────────────────────────────────
if [ -f "$GIT_DIR/.gitconfig" ]; then
  if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$(date +%Y%m%d%H%M%S)"
    log_warn ".gitconfig existant sauvegardé."
  fi
  ln -sf "$GIT_DIR/.gitconfig" "$HOME/.gitconfig"
  log_ok ".gitconfig lié."
fi

# ─── .gitignore global ────────────────────────────────────────────────────────
if [ -f "$GIT_DIR/.gitignore_global" ]; then
  ln -sf "$GIT_DIR/.gitignore_global" "$HOME/.gitignore_global"
  git config --global core.excludesfile "$HOME/.gitignore_global"
  log_ok ".gitignore_global lié et configuré."
fi

# ─── Git LFS (si présent dans apt.txt, sinon skip) ───────────────────────────
if command -v git-lfs &>/dev/null; then
  git lfs install --skip-repo 2>/dev/null || true
  log_ok "Git LFS configuré."
fi
