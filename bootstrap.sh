#!/bin/bash
# bootstrap.sh

set -e # Bei Fehlern sofort abbrechen
set -x

echo "🚀 Starte System-Bootstrap..."

# 1. Git installieren (falls nicht vorhanden)
if ! command -v git &> /dev/null; then
    echo "📦 Installiere Git..."
    sudo dnf install -y git
fi

# 2. Repo klonen (falls noch nicht geschehen)
TARGET_DIR="$HOME/.dotfiles"
REPO_URL_HTTPS="https://github.com/snwiem/dotfiles.git"
REPO_URL_SSH="git@github.com:snwiem/dotfiles.git"
if [ ! -d "$TARGET_DIR" ]; then
echo "📥 Klone Dotfiles-Repository via HTTPS..."
    git clone "$REPO_URL_HTTPS" "$TARGET_DIR"
    
    echo "🔄 Stelle Remote-URL auf SSH um..."
    cd "$TARGET_DIR"
    git remote set-url origin "$REPO_URL_SSH"
    cd - > /dev/null
fi

# 3. Mise installieren (falls nicht vorhanden)
if ! command -v mise &> /dev/null; then
    echo "🛠️ Installiere Mise..."
    curl https://mise.run | sh
fi

# 4. Config-Verzeichnis erstellen und verlinken
mkdir -p ~/.config/mise
if [ ! -f ~/.config/mise/config.toml ]; then
    ln -s "$TARGET_DIR/mise/config.toml" ~/.config/mise/config.toml
fi

# 5. Mise Bootstrap ausführen (installiert Zsh, Runtimes etc.)
echo "⚙️ Starte Mise-Bootstrap..."
MISE_YES=true ~/.local/bin/mise bootstrap

echo "************"
# 6. Shell wechseln
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 Wechsle Standard-Shell zu Zsh..."
#    sudo dnf install -y util-linux-user # Für chsh benötigt
    chsh -s "$(which zsh)"
fi

echo "✅ Bootstrap abgeschlossen! Bitte starte deine Shell neu."
