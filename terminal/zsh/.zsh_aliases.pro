# ─── .zsh_aliases.pro — Aliases spécifiques à la machine pro ─────────────────

# ─── Playiad ──────────────────────────────────────────────────────────────────
alias piad="ssh-add ~/.ssh/id_ed25519-github && cd /home/www/Playiad/ && make start_all"
alias piad_all="ssh-add ~/.ssh/id_ed25519-github && cd /home/www/Playiad/ && make start_all start_monitoring_all"
alias stopiad="cd /home/www/Playiad/ && make stop down"
alias stopiad_all="cd /home/www/Playiad/ && make stop_monitoring_all stop down"
alias docker_reset="stopiad_all && sudo systemctl restart docker && piad"

# ─── AWS SSO ──────────────────────────────────────────────────────────────────
function aws_sso_login() {
  local PROFILE="$1"
  if [[ -z "$PROFILE" ]]; then
    echo "Usage : aws_sso_login <profile>"
    return 1
  fi
  aws sso login --profile "$PROFILE"
  aws-export-credentials --profile "$PROFILE" --credentials-file-profile "$PROFILE-export"
  # Décommenter pour définir le profil par défaut :
  # export AWS_DEFAULT_PROFILE="$PROFILE"
}
