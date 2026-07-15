#!/bin/bash
# bootstrap.sh

set -e # Bei Fehlern sofort abbrechen

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
export MISE_VERBOSE=1
export MISE_YES=true
~/.local/bin/mise bootstrap --yes

LOCAL_GIT_DIR="$HOME/.config/git"
LOCAL_GIT="$LOCAL_GIT_DIR/config.local"
if [ ! -f "$LOCAL_GIT" ]; then
    echo "👤 Git-Identität einrichten..."
    mkdir -p "$LOCAL_GIT_DIR" # Sicherstellen, dass der Ordner existiert
    
    read -p "Gib deinen vollständigen Namen für Git ein: " git_name < /dev/tty
    read -p "Gib deine E-Mail-Adresse für Git ein: " git_email < /dev/tty
    
    cat <<EOF > "$LOCAL_GIT"
[user]
    name = $git_name
    email = $git_email
EOF
    echo "✅ $LOCAL_GIT wurde erfolgreich erstellt!"
fi

echo "✅ Bootstrap abgeschlossen! Bitte starte deine Shell neu."
