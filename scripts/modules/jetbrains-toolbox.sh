#!/usr/bin/env bash
# Module : jetbrains-toolbox
# Installe JetBrains Toolbox depuis le .tar.gz officiel dans /opt/
# et configure l'ouverture automatique au démarrage de session

set -euo pipefail

INSTALL_DIR="/opt/jetbrains-toolbox"
BINARY="$INSTALL_DIR/jetbrains-toolbox"
AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/jetbrains-toolbox.desktop"

if [ -f "$BINARY" ]; then
  log_warn "JetBrains Toolbox déjà installé dans $INSTALL_DIR"
  # On s'assure quand même que l'autostart est en place
else
  log_info "Récupération de la dernière version de JetBrains Toolbox..."

  # API JetBrains pour la dernière version
  TOOLBOX_JSON="$(curl -fsSL \
    'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release')"

  TARBALL_URL="$(echo "$TOOLBOX_JSON" \
    | grep -o '"linux":{[^}]*}' \
    | grep -o '"link":"[^"]*"' \
    | head -1 \
    | grep -o 'https://[^"]*')"

  if [ -z "$TARBALL_URL" ]; then
    log_error "Impossible de récupérer l'URL. Télécharge manuellement depuis :"
    log_error "https://www.jetbrains.com/toolbox-app/"
    exit 1
  fi

  log_info "Téléchargement : $TARBALL_URL"
  TMP_TAR="$(mktemp /tmp/jetbrains-toolbox-XXXXXX.tar.gz)"
  curl -fsSL -o "$TMP_TAR" "$TARBALL_URL"

  log_info "Extraction dans $INSTALL_DIR..."
  sudo mkdir -p "$INSTALL_DIR"
  sudo tar -xzf "$TMP_TAR" -C "$INSTALL_DIR" --strip-components=1
  sudo chmod +x "$BINARY"
  rm -f "$TMP_TAR"

  log_ok "JetBrains Toolbox installé dans $INSTALL_DIR"
fi

# ─── Autostart au démarrage de session ───────────────────────────────────────
mkdir -p "$AUTOSTART_DIR"

if [ ! -f "$AUTOSTART_FILE" ]; then
  log_info "Configuration de l'autostart..."
  cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Exec=$BINARY
Icon=$INSTALL_DIR/toolbox.svg
Comment=JetBrains Toolbox App
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false
EOF
  log_ok "Autostart configuré : $AUTOSTART_FILE"
else
  log_warn "Autostart déjà en place."
fi

# ─── Lien symbolique dans PATH ────────────────────────────────────────────────
if [ ! -L /usr/local/bin/jetbrains-toolbox ]; then
  sudo ln -sf "$BINARY" /usr/local/bin/jetbrains-toolbox
  log_ok "Symlink : /usr/local/bin/jetbrains-toolbox"
fi
