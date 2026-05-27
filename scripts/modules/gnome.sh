#!/usr/bin/env bash
# Module : gnome
# Installe les extensions GNOME et restaure la config dconf (dock, etc.)

set -euo pipefail

GNOME_DIR="$DOTFILES_DIR/gnome"
DCONF_FILE="$GNOME_DIR/dconf-settings.ini"
EXTENSIONS_LIST="$GNOME_DIR/extensions.txt"

# ─── gnome-extensions-cli ─────────────────────────────────────────────────────
# Outil pip qui permet d'installer des extensions sans navigateur
install_gext() {
  if ! command -v gnome-extensions-cli &>/dev/null; then
    log_info "Installation de gnome-extensions-cli..."
    # Vérif pipx ou pip
    if command -v pipx &>/dev/null; then
      pipx install gnome-extensions-cli
    elif command -v pip3 &>/dev/null; then
      pip3 install --user gnome-extensions-cli
    else
      sudo apt-get install -y python3-pip
      pip3 install --user gnome-extensions-cli
    fi
    log_ok "gnome-extensions-cli installé."
  fi
}

# ─── Extensions ───────────────────────────────────────────────────────────────
install_extensions() {
  if [ ! -f "$EXTENSIONS_LIST" ]; then
    log_warn "Pas de liste d'extensions : $EXTENSIONS_LIST"
    return
  fi

  install_gext

  log_info "Installation des extensions GNOME..."
  while IFS= read -r line; do
    [[ "$line" =~ ^#|^$ ]] && continue
    # Format : uuid|extension-id (ex: system-monitor-next@paradoxxx.zero.gmail.com)
    ext_uuid="$line"
    log_info "Extension : $ext_uuid"
    gnome-extensions-cli install "$ext_uuid" \
      && log_ok "Extension '$ext_uuid' installée." \
      || log_warn "Échec pour '$ext_uuid' (peut-être déjà installée)."
  done < "$EXTENSIONS_LIST"
}

# ─── dconf (dock + paramètres GNOME) ─────────────────────────────────────────
restore_dconf() {
  if [ ! -f "$DCONF_FILE" ]; then
    log_warn "Pas de dump dconf : $DCONF_FILE"
    log_warn "Lance './scripts/capture.sh gnome' pour capturer ta config actuelle."
    return
  fi

  if ! command -v dconf &>/dev/null; then
    sudo apt-get install -y dconf-cli
  fi

  log_info "Restauration dconf..."
  dconf load / < "$DCONF_FILE"
  log_ok "Config dconf restaurée."
}

install_extensions
restore_dconf
