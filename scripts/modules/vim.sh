#!/usr/bin/env bash
# Module : vim
# Installe vim et déploie la config .vimrc

set -euo pipefail

VIM_SRC="$DOTFILES_DIR/vim/.vimrc"

# ─── Installation ─────────────────────────────────────────────────────────────
if ! command -v vim &>/dev/null; then
  log_info "Installation de vim..."
  sudo apt-get install -y vim
  log_ok "Vim installé."
else
  log_warn "Vim déjà installé : $(vim --version | head -1)"
fi

# ─── .vimrc ───────────────────────────────────────────────────────────────────
if [ -f "$VIM_SRC" ]; then
  if [ -f "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ]; then
    cp "$HOME/.vimrc" "$HOME/.vimrc.backup.$(date +%Y%m%d%H%M%S)"
    log_warn ".vimrc existant sauvegardé."
  fi
  ln -sf "$VIM_SRC" "$HOME/.vimrc"
  log_ok ".vimrc lié."
else
  log_warn "Pas de .vimrc source trouvé : $VIM_SRC"
  log_warn "Lance './scripts/capture.sh vim' pour capturer ta config actuelle."
fi

# ─── vim-plug (gestionnaire de plugins, si utilisé) ───────────────────────────
PLUG_FILE="$HOME/.vim/autoload/plug.vim"
if [ ! -f "$PLUG_FILE" ]; then
  # Vérifie si .vimrc utilise vim-plug avant d'installer
  if [ -f "$VIM_SRC" ] && grep -q "plug#begin" "$VIM_SRC" 2>/dev/null; then
    log_info "Installation de vim-plug..."
    curl -fsSLo "$PLUG_FILE" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    log_ok "vim-plug installé."
    log_info "Installation des plugins vim (PlugInstall)..."
    vim +PlugInstall +qall
    log_ok "Plugins vim installés."
  fi
fi
