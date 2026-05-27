#!/usr/bin/env bash
# Module : zsh
# Installe Oh My Zsh, les plugins et configure le shell

set -euo pipefail

ZSH_DIR="$DOTFILES_DIR/terminal/zsh"

# ─── Zsh ──────────────────────────────────────────────────────────────────────
if ! command -v zsh &>/dev/null; then
  log_info "Installation de zsh..."
  sudo apt-get install -y zsh
fi

# ─── Oh My Zsh ────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log_info "Installation de Oh My Zsh..."
  # Installation non-interactive (pas de changement de shell immédiat)
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log_ok "Oh My Zsh installé."
else
  log_warn "Oh My Zsh déjà installé, skip."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ─── Plugins ──────────────────────────────────────────────────────────────────
install_plugin() {
  local name="$1"
  local repo="$2"
  local dest="$ZSH_CUSTOM/plugins/$name"
  if [ ! -d "$dest" ]; then
    log_info "Plugin : $name"
    git clone --depth=1 "https://github.com/$repo" "$dest"
    log_ok "Plugin '$name' installé."
  else
    log_warn "Plugin '$name' déjà présent."
  fi
}

install_plugin "zsh-autosuggestions"  "zsh-users/zsh-autosuggestions"
install_plugin "zsh-syntax-highlighting" "zsh-users/zsh-syntax-highlighting"
install_plugin "zsh-completions"      "zsh-users/zsh-completions"
install_plugin "you-should-use"       "MichaelAquilina/zsh-you-should-use"

# ─── Thème Powerlevel10k (optionnel, décommenter si souhaité) ─────────────────
# install_theme() {
#   local dest="$ZSH_CUSTOM/themes/powerlevel10k"
#   if [ ! -d "$dest" ]; then
#     log_info "Thème : powerlevel10k"
#     git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$dest"
#   fi
# }
# install_theme

# ─── Symlink .zshrc ───────────────────────────────────────────────────────────
if [ -f "$ZSH_DIR/.zshrc" ]; then
  if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    log_warn ".zshrc existant sauvegardé."
  fi
  ln -sf "$ZSH_DIR/.zshrc" "$HOME/.zshrc"
  log_ok ".zshrc lié."
fi

if [ -f "$ZSH_DIR/.zshenv" ]; then
  ln -sf "$ZSH_DIR/.zshenv" "$HOME/.zshenv"
  log_ok ".zshenv lié."
fi

if [ -f "$ZSH_DIR/.zsh_aliases" ]; then
  ln -sf "$ZSH_DIR/.zsh_aliases" "$HOME/.zsh_aliases"
  log_ok ".zsh_aliases lié."
fi

# ─── Shell par défaut ─────────────────────────────────────────────────────────
ZSH_BIN="$(which zsh)"
if [ "$SHELL" != "$ZSH_BIN" ]; then
  log_info "Changement du shell par défaut vers zsh..."
  chsh -s "$ZSH_BIN"
  log_ok "Shell par défaut : $ZSH_BIN (effectif à la prochaine session)."
fi
