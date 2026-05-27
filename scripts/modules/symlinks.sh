#!/usr/bin/env bash
# Module : symlinks
# Crée tous les liens symboliques depuis ~/.dotfiles vers leur emplacement standard

set -euo pipefail

PROFILE="${MACHINE_PROFILE:-perso}"

# Format : "source_relatif_au_dotfiles_dir|destination_absolue"
SYMLINKS=(
  "terminal/zsh/.zshrc|$HOME/.zshrc"
  "terminal/zsh/.zshenv|$HOME/.zshenv"
  "terminal/zsh/.zsh_aliases|$HOME/.zsh_aliases"
  "terminal/zsh/.zsh_aliases.perso|$HOME/.zsh_aliases.perso"
  "terminal/zsh/.zsh_aliases.pro|$HOME/.zsh_aliases.pro"
  "terminal/zsh/.zshenv.perso|$HOME/.zshenv.perso"
  "terminal/zsh/.zshenv.pro|$HOME/.zshenv.pro"
  "terminal/terminator/config|$HOME/.config/terminator/config"
  "git/.gitconfig|$HOME/.gitconfig"
  "git/.gitignore_global|$HOME/.gitignore_global"
  "vim/.vimrc|$HOME/.vimrc"
)

for entry in "${SYMLINKS[@]}"; do
  src_rel="${entry%%|*}"
  dest="${entry##*|}"
  src="$DOTFILES_DIR/$src_rel"

  if [ ! -f "$src" ] && [ ! -d "$src" ]; then
    log_warn "Source absente, skip : $src"
    continue
  fi

  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    cp -r "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
    log_warn "Sauvegarde : $dest"
    rm -rf "$dest"
  fi

  ln -sf "$src" "$dest"
  log_ok "Lien : $dest → $src"
done

# ─── Écrit MACHINE_PROFILE dans .zshenv ───────────────────────────────────────
ZSHENV="$HOME/.zshenv"
if [ -f "$ZSHENV" ]; then
  # Met à jour la valeur si elle existe déjà
  if grep -q 'MACHINE_PROFILE=' "$ZSHENV"; then
    sed -i "s/export MACHINE_PROFILE=.*/export MACHINE_PROFILE=\"$PROFILE\"/" "$ZSHENV"
  else
    echo "export MACHINE_PROFILE=\"$PROFILE\"" >> "$ZSHENV"
  fi
  log_ok "MACHINE_PROFILE=\"$PROFILE\" écrit dans .zshenv"
fi