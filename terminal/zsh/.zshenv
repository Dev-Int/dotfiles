# ─── .zshenv — Chargé pour tous les shells (interactifs ou non) ───────────────
# Ne mettre ici que ce qui est nécessaire à TOUS les shells

# ─── Profil machine (positionné par install.sh) ───────────────────────────────
# Valeurs possibles : perso | pro
export MACHINE_PROFILE="${MACHINE_PROFILE:-perso}"

# ─── PATH commun ──────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# ─── Éditeur par défaut ───────────────────────────────────────────────────────
export EDITOR="vim"
