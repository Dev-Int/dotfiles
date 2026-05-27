#!/usr/bin/env bash
# =============================================================================
# dotfiles / install.sh — Point d'entrée principal
# Usage : ./install.sh [module1] [module2] ...
#         ./install.sh all
#         ./install.sh          → affiche l'aide
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$DOTFILES_DIR/scripts/modules"

# Couleurs
export RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
export BLUE='\033[0;34m' CYAN='\033[0;36m' BOLD='\033[1m' RESET='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_section() { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

export DOTFILES_DIR
export -f log_info log_ok log_warn log_error log_section

# Détection OS
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$NAME"
    OS_VERSION="$VERSION_ID"
  else
    OS_NAME="Unknown"; OS_VERSION="Unknown"
  fi
  log_info "OS détecté : $OS_NAME $OS_VERSION"
  export OS_NAME OS_VERSION
}

# Liste des modules disponibles
AVAILABLE_MODULES=(
  "packages"           # Paquets apt, snap
  "symlinks"           # Création des liens symboliques
  "zsh"                # Oh My Zsh + plugins
  "terminator"         # Config Terminator
  "vim"                # Config Vim + vim-plug
  "git"                # Config git globale
  "gnome"              # Extensions + paramètres GNOME
  "fonts"              # PowerlineSymbols + Ubuntu Mono
  "docker"             # Docker Engine via repo officiel
  "slack"              # Slack via .deb officiel
  "zen-browser"        # Zen Browser via .deb GitHub release
  "jetbrains-toolbox"  # JetBrains Toolbox dans /opt/ + autostart
)

usage() {
  echo -e "\n${BOLD}Usage :${RESET} $0 [module...] | all\n"
  echo -e "${BOLD}Modules disponibles :${RESET}"
  for m in "${AVAILABLE_MODULES[@]}"; do
    local desc
    desc=$(get_module_desc "$m")
    printf "  ${CYAN}%-15s${RESET} %s\n" "$m" "$desc"
  done
  echo -e "\n${BOLD}Exemples :${RESET}"
  echo "  $0 all                   # Tout installer"
  echo "  $0 zsh terminator        # Seulement zsh + terminator"
  echo "  $0 gnome                 # Seulement GNOME"
  echo ""
}

get_module_desc() {
  case "$1" in
    packages)        echo "Paquets apt, snap" ;;
    symlinks)        echo "Liens symboliques vers ~/.dotfiles" ;;
    zsh)             echo "Oh My Zsh + plugins + thème" ;;
    terminator)      echo "Config Terminator (layouts, profils)" ;;
    vim)             echo ".vimrc + vim-plug si utilisé" ;;
    git)             echo "gitconfig, gitignore global" ;;
    gnome)           echo "Extensions GNOME + dconf ciblé" ;;
    fonts)           echo "PowerlineSymbols (agnoster) + Ubuntu Mono" ;;
    docker)          echo "Docker Engine via repo officiel" ;;
    php)             echo "Composer, Symfony CLI" ;;
    slack)           echo "Slack via .deb officiel" ;;
    zen-browser)     echo "Zen Browser via .deb (GitHub release)" ;;
    jetbrains-toolbox) echo "JetBrains Toolbox dans /opt/ + autostart" ;;
    *)          echo "" ;;
  esac
}

run_module() {
  local module="$1"
  local module_script="$MODULES_DIR/${module}.sh"

  if [ ! -f "$module_script" ]; then
    log_error "Module introuvable : $module_script"
    return 1
  fi

  log_section "Module : $module"
  bash "$module_script" && log_ok "Module '$module' terminé." || {
    log_error "Module '$module' a échoué."
    return 1
  }
}

# ─── Profil machine ───────────────────────────────────────────────────────────
select_profile() {
  echo -e "\n${BOLD}Quel profil pour cette machine ?${RESET}"
  echo -e "  ${CYAN}1)${RESET} Perso"
  echo -e "  ${CYAN}2)${RESET} Pro"
  echo -e "  ${CYAN}3)${RESET} Les deux\n"
  read -rp "Choix [1/2/3] : " choice
  case "$choice" in
    1) MACHINE_PROFILE="perso" ;;
    2) MACHINE_PROFILE="pro" ;;
    3) MACHINE_PROFILE="all" ;;
    *) log_warn "Choix invalide, profil 'all' utilisé par défaut." ; MACHINE_PROFILE="all" ;;
  esac
  export MACHINE_PROFILE
  log_info "Profil sélectionné : ${BOLD}$MACHINE_PROFILE${RESET}"
}



detect_os

if [ $# -eq 0 ]; then
  usage
  exit 0
fi

select_profile

if [ "$1" = "all" ]; then
  for m in "${AVAILABLE_MODULES[@]}"; do
    run_module "$m"
  done
else
  for arg in "$@"; do
    run_module "$arg"
  done
fi

echo -e "\n${GREEN}${BOLD}✓ Installation terminée !${RESET}\n"