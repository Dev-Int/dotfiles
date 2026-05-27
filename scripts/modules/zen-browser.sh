#!/usr/bin/env bash
# Module : zen-browser
# Installe Zen Browser via .deb (GitHub release) — plus léger que Flatpak
# La config, extensions et workspaces sont restaurés automatiquement
# via la connexion au compte Zen (Firefox Sync)

set -euo pipefail

if flatpak list 2>/dev/null | grep -q "app.zen_browser.zen"; then
  log_warn "Zen Browser installé via Flatpak détecté."
  log_warn "Pour gagner de la place, désinstalle-le : sudo flatpak uninstall app.zen_browser.zen"
  log_warn "Puis relance ce module pour installer le .deb."
  exit 0
fi

if dpkg -l 2>/dev/null | grep -q "zen-browser"; then
  log_warn "Zen Browser (.deb) déjà installé."
  exit 0
fi

log_info "Récupération de la dernière release Zen Browser..."
LATEST_JSON="$(curl -fsSL https://api.github.com/repos/zen-browser/desktop/releases/latest)"
DEB_URL="$(echo "$LATEST_JSON" | grep -o '"browser_download_url": *"[^"]*\.deb"' | head -1 | grep -o 'https://[^"]*')"

if [ -z "$DEB_URL" ]; then
  log_error "Impossible de trouver l'URL du .deb."
  log_error "Vérifie : https://github.com/zen-browser/desktop/releases"
  exit 1
fi

log_info "Téléchargement : $DEB_URL"
TMP_DEB="$(mktemp /tmp/zen-browser-XXXXXX.deb)"
curl -fsSL -o "$TMP_DEB" "$DEB_URL"
sudo apt-get install -y "$TMP_DEB"
rm -f "$TMP_DEB"
log_ok "Zen Browser installé (.deb)."

log_info "Post-install : connecte ton compte Zen pour restaurer"
log_info "  extensions, préférences et workspaces automatiquement."
log_info "  Pense à vérifier que 'Espaces de travail' est coché dans Paramètres → Sync."
