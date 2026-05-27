# dotfiles

Config personnelle — Ubuntu 22.04 / 24.04.

## 🚀 Installation rapide

```bash
git clone https://github.com/TON_USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh scripts/capture.sh scripts/modules/*.sh
./install.sh all
```

## 📦 Modules disponibles

| Module              | Description                                        | Source                    |
|---------------------|----------------------------------------------------|---------------------------|
| `packages`          | Paquets apt, snap (Deezer, Teams)                  | apt.txt / snap.txt        |
| `symlinks`          | Liens symboliques vers `~/.dotfiles`               | —                         |
| `zsh`               | Oh My Zsh + plugins                                | terminal/zsh/             |
| `terminator`        | Config Terminator (layouts, profils, couleurs)     | terminal/terminator/      |
| `vim`               | `.vimrc` + vim-plug si utilisé                     | vim/.vimrc                |
| `git`               | `.gitconfig`, `.gitignore_global`                  | git/                      |
| `gnome`             | Extensions GNOME + restauration dconf (dock...)    | gnome/                    |
| `fonts`             | JetBrains Mono Nerd Font                           | —                         |
| `slack`             | Slack via `.deb` officiel                          | —                         |
| `zen-browser`       | Zen Browser via `.deb` (GitHub release)            | apps/zen-browser/         |
| `jetbrains-toolbox` | JetBrains Toolbox dans `/opt/` + autostart session | —                         |

## 🎯 Installer seulement certains modules

```bash
./install.sh zsh terminator vim
./install.sh slack zen-browser jetbrains-toolbox
./install.sh gnome
```

## 💾 Capturer ta config actuelle

Après avoir modifié une config sur ta machine, exporte-la dans le repo :

```bash
./scripts/capture.sh all          # Tout capturer
./scripts/capture.sh gnome        # dconf + liste extensions
./scripts/capture.sh terminator
./scripts/capture.sh zsh
./scripts/capture.sh vim
./scripts/capture.sh zen-browser  # user.js + userChrome.css
./scripts/capture.sh packages     # Mettre à jour apt.txt / snap.txt
```

Puis commit :

```bash
git add -A && git commit -m "chore: update configs"
git push
```

## 🗂️ Structure

```
~/.dotfiles/
├── install.sh
├── scripts/
│   ├── capture.sh
│   └── modules/
│       ├── packages.sh
│       ├── symlinks.sh
│       ├── zsh.sh
│       ├── terminator.sh
│       ├── vim.sh
│       ├── git.sh
│       ├── gnome.sh
│       ├── fonts.sh
│       ├── slack.sh
│       ├── zen-browser.sh
│       └── jetbrains-toolbox.sh
├── packages/
│   ├── apt.txt
│   └── snap.txt          ← teams-for-linux, deezer-unofficial-player
├── gnome/
│   ├── extensions.txt
│   └── dconf-settings.ini
├── terminal/
│   ├── terminator/config
│   └── zsh/
│       ├── .zshrc
│       ├── .zshenv
│       └── .zsh_aliases
├── vim/
│   └── .vimrc
└── git/
    ├── .gitconfig
    └── .gitignore_global
```

## 🔒 Sécurité

Ce repo est **public** — ne jamais y mettre :
- Clés SSH / GPG
- Tokens / mots de passe
- `.env` avec des secrets

Pour les secrets, utilise Proton Pass ou un vault séparé (privé).
