# ─── Oh My Zsh ────────────────────────────────────────────────────────────────
export TERM="xterm-256color"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(
  git
  composer
  symfony
  docker
  docker-compose
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  you-should-use
  history
  z
)

source "$ZSH/oh-my-zsh.sh"

# ─── Prompt ───────────────────────────────────────────────────────────────────
# Masque le contexte user@host dans le prompt agnoster
prompt_context() {}

# Curseur clignotant après chaque prompt
precmd() { echo -ne '\e[1 q'; }

# ─── Historique ───────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ─── Aliases ──────────────────────────────────────────────────────────────────
[ -f "$HOME/.zsh_aliases" ] && source "$HOME/.zsh_aliases"
[ -f "$HOME/.zsh_aliases.$MACHINE_PROFILE" ] && source "$HOME/.zsh_aliases.$MACHINE_PROFILE"

# ─── Config spécifique à la machine ──────────────────────────────────────────
[ -f "$HOME/.zshenv.$MACHINE_PROFILE" ] && source "$HOME/.zshenv.$MACHINE_PROFILE"
