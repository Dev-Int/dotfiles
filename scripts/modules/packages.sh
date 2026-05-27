#!/usr/bin/env bash
# Module : packages
# Installe les paquets apt, snap et npm globaux

set -euo pipefail

APT_LIST="$DOTFILES_DIR/packages/apt.txt"
SNAP_LIST="$DOTFILES_DIR/packages/snap.txt"
NPM_LIST="$DOTFILES_DIR/packages/npm-global.txt"

log_info "Mise à jour apt..."
sudo apt-get update -qq

# ─── APT ──────────────────────────────────────────────────────────────────────
if [ -f "$APT_LIST" ]; then
  log_info "Installation des paquets apt..."
  # Filtre les lignes vides et commentaires
  mapfile -t packages < <(grep -v '^\s*#' "$APT_LIST" | grep -v '^\s*$')
  if [ ${#packages[@]} -gt 0 ]; then
    sudo apt-get install -y "${packages[@]}"
    log_ok "${#packages[@]} paquets apt installés."
  fi
fi

# ─── SNAP ─────────────────────────────────────────────────────────────────────
if [ -f "$SNAP_LIST" ]; then
  log_info "Installation des paquets snap..."
  while IFS= read -r line; do
    [[ "$line" =~ ^#|^$ ]] && continue
    # Support options : "package --classic" ou "package --channel=..."
    pkg=$(echo "$line" | awk '{print $1}')
    opts=$(echo "$line" | cut -s -d' ' -f2-)
    if snap list "$pkg" &>/dev/null; then
      log_warn "Snap '$pkg' déjà installé, skip."
    else
      # shellcheck disable=SC2086
      sudo snap install "$pkg" $opts && log_ok "Snap '$pkg' installé."
    fi
  done < "$SNAP_LIST"
fi

# ─── NPM GLOBAL ───────────────────────────────────────────────────────────────
if [ -f "$NPM_LIST" ] && command -v npm &>/dev/null; then
  log_info "Installation des paquets npm globaux..."
  mapfile -t npm_pkgs < <(grep -v '^\s*#' "$NPM_LIST" | grep -v '^\s*$')
  if [ ${#npm_pkgs[@]} -gt 0 ]; then
    npm install -g "${npm_pkgs[@]}"
    log_ok "${#npm_pkgs[@]} paquets npm globaux installés."
  fi
elif [ -f "$NPM_LIST" ]; then
  log_warn "npm non trouvé, skip des paquets npm."
fi
