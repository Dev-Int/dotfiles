#!/usr/bin/env bash
# =============================================================================
# scripts/capture.sh — Capture la config actuelle vers le repo dotfiles
# Usage : ./scripts/capture.sh [cible]
#         ./scripts/capture.sh all
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

log_ok()   { echo -e "${GREEN}[CAPTURE]${RESET} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET}    $*"; }
log_info() { echo -e "${CYAN}[INFO]${RESET}    $*"; }

capture_zsh() {
  log_info "Capture zsh..."
  local zsh_dir="$DOTFILES_DIR/terminal/zsh"

  cp "$HOME/.zshrc"              "$zsh_dir/.zshrc"              2>/dev/null && log_ok ".zshrc"
  cp "$HOME/.zshenv"             "$zsh_dir/.zshenv"             2>/dev/null && log_ok ".zshenv"             || true
  cp "$HOME/.zsh_aliases"        "$zsh_dir/.zsh_aliases"        2>/dev/null && log_ok ".zsh_aliases"        || true
  cp "$HOME/.zsh_aliases.perso"  "$zsh_dir/.zsh_aliases.perso"  2>/dev/null && log_ok ".zsh_aliases.perso"  || true
  cp "$HOME/.zsh_aliases.pro"    "$zsh_dir/.zsh_aliases.pro"    2>/dev/null && log_ok ".zsh_aliases.pro"    || true
  cp "$HOME/.zshenv.perso"       "$zsh_dir/.zshenv.perso"       2>/dev/null && log_ok ".zshenv.perso"       || true
  cp "$HOME/.zshenv.pro"         "$zsh_dir/.zshenv.pro"         2>/dev/null && log_ok ".zshenv.pro"         || true
}

capture_terminator() {
  log_info "Capture Terminator..."
  local src="$HOME/.config/terminator/config"
  local dest="$DOTFILES_DIR/terminal/terminator/config"
  if [ -f "$src" ]; then
    cp "$src" "$dest" && log_ok "terminator/config"
  else
    log_warn "Config Terminator introuvable : $src"
  fi
}

capture_gnome() {
  log_info "Capture dconf (GNOME)..."
  local dest="$DOTFILES_DIR/gnome"

  # Dock (position, taille, apps épinglées)
  dconf dump /org/gnome/shell/extensions/dash-to-dock/ \
    > "$dest/dconf-dock.ini" 2>/dev/null \
    && log_ok "dconf-dock.ini" || log_warn "dash-to-dock non trouvé"

  # GNOME Shell (thème, comportement)
  dconf dump /org/gnome/shell/ \
    > "$dest/dconf-shell.ini" 2>/dev/null \
    && log_ok "dconf-shell.ini"

  # Raccourcis clavier
  dconf dump /org/gnome/settings-daemon/plugins/media-keys/ \
    > "$dest/dconf-keybindings.ini" 2>/dev/null \
    && log_ok "dconf-keybindings.ini"

  dconf dump /org/gnome/desktop/wm/keybindings/ \
    >> "$dest/dconf-keybindings.ini" 2>/dev/null \
    && log_ok "dconf-keybindings.ini (wm)"

  # Paramètres desktop (thème GTK, icônes, polices)
  dconf dump /org/gnome/desktop/interface/ \
    > "$dest/dconf-interface.ini" 2>/dev/null \
    && log_ok "dconf-interface.ini"

  log_info "Capture liste extensions GNOME actives..."
  gnome-extensions list --enabled > "$dest/extensions.txt" 2>/dev/null \
    && log_ok "extensions.txt mis à jour." \
    || log_warn "gnome-extensions non disponible."
}

capture_git() {
  log_info "Capture git..."
  cp "$HOME/.gitconfig"        "$DOTFILES_DIR/git/.gitconfig"        2>/dev/null && log_ok ".gitconfig"
  cp "$HOME/.gitignore_global" "$DOTFILES_DIR/git/.gitignore_global" 2>/dev/null && log_ok ".gitignore_global" || true
}

capture_vim() {
  log_info "Capture vim..."
  cp "$HOME/.vimrc" "$DOTFILES_DIR/vim/.vimrc" 2>/dev/null && log_ok ".vimrc" || log_warn ".vimrc introuvable"
}

capture_packages() {
  log_info "Capture paquets snap..."

  if command -v snap &>/dev/null; then
    snap list | tail -n +2 | awk '{print $1}' > "$DOTFILES_DIR/packages/snap.txt"
    log_ok "snap.txt mis à jour."
  fi

  # Génère une liste de référence des paquets apt installés manuellement
  # sans écraser apt.txt qui est une liste curative maintenue à la main
  log_info "Génération de apt-installed.txt (référence, ne pas committer)..."
  comm -23 \
    <(apt-mark showmanual | sort) \
    <(gzip -dc /var/lib/apt/extended_states 2>/dev/null | grep -oP '(?<=Package: ).*' | sort) \
    > "$DOTFILES_DIR/packages/apt-installed.txt" \
    && log_warn "apt-installed.txt généré pour référence — ne pas committer, apt.txt est la liste curative."
}

# ─── Main ─────────────────────────────────────────────────────────────────────
case "${1:-}" in
  zsh)        capture_zsh ;;
  terminator) capture_terminator ;;
  gnome)      capture_gnome ;;
  git)        capture_git ;;
  vim)        capture_vim ;;
  packages)   capture_packages ;;
  all)
    capture_zsh
    capture_terminator
    capture_gnome
    capture_git
    capture_vim
    capture_packages
    ;;
  *)
    echo -e "\n${BOLD}Usage :${RESET} $0 [zsh|terminator|gnome|git|vim|packages|all]\n"
    echo "Capture la config actuelle de ta machine vers le repo dotfiles."
    exit 0
    ;;
esac

echo -e "\n${GREEN}${BOLD}✓ Capture terminée.${RESET}"
echo -e "Pense à ${CYAN}git add && git commit${RESET} pour sauvegarder les changements.\n"