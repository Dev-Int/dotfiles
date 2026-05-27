#!/usr/bin/env bash
# Module : gnome
# Installe les extensions GNOME et restaure la config dconf ciblée

set -euo pipefail

GNOME_DIR="$DOTFILES_DIR/gnome"

# ─── Dépendances extensions ───────────────────────────────────────────────────
log_info "Installation des dépendances pour les extensions..."
sudo apt-get install -y \
  gir1.2-gtop-2.0 \
  gir1.2-nm-1.0 \
  gir1.2-clutter-1.0
log_ok "Dépendances installées."

# ─── gnome-extensions-cli ─────────────────────────────────────────────────────
install_gext() {
  if ! command -v gnome-extensions-cli &>/dev/null; then
    log_info "Installation de gnome-extensions-cli..."
    if command -v pipx &>/dev/null; then
      pipx install gnome-extensions-cli
    else
      sudo apt-get install -y python3-pip
      pip3 install --user gnome-extensions-cli
    fi
    log_ok "gnome-extensions-cli installé."
  fi
}

# ─── Extensions ───────────────────────────────────────────────────────────────
install_extensions() {
  if [ ! -f "$GNOME_DIR/extensions.txt" ]; then
    log_warn "Pas de liste d'extensions : $GNOME_DIR/extensions.txt"
    return
  fi

  install_gext

  log_info "Installation des extensions GNOME..."
  while IFS= read -r line; do
    [[ "$line" =~ ^#|^$ ]] && continue
    if gnome-extensions-cli install "$line" 2>&1 | grep -q "Cannot find"; then
      log_warn "Extension introuvable sur extensions.gnome.org : '$line'"
    else
      log_ok "Extension '$line' installée."
    fi
  done < "$GNOME_DIR/extensions.txt"
}

# ─── dconf ciblé ──────────────────────────────────────────────────────────────
restore_dconf() {
  if ! command -v dconf &>/dev/null; then
    sudo apt-get install -y dconf-cli
  fi

  local files=(
    "dconf-dock.ini:/org/gnome/shell/extensions/dash-to-dock/"
    "dconf-shell.ini:/org/gnome/shell/"
    "dconf-keybindings.ini:/org/gnome/settings-daemon/plugins/media-keys/"
    "dconf-interface.ini:/org/gnome/desktop/interface/"
  )

  for entry in "${files[@]}"; do
    local file="${entry%%:*}"
    local path="${entry##*:}"
    local src="$GNOME_DIR/$file"

    if [ -f "$src" ] && [ -s "$src" ]; then
      dconf load "$path" < "$src"
      log_ok "dconf restauré : $path"
    else
      log_warn "Fichier absent ou vide, skip : $src"
    fi
  done
}

install_extensions
restore_dconf