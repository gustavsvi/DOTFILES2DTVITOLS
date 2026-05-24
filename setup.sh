#!/bin/bash

# Apturēt skriptu, ja kāda komanda izpildās ar kļūdu
set -e 

echo "=== Setting up the DOTFILES ==="

# ---------------------------------------------------------
# Funkciju definīcijas (Jābūt skripta sākumā)
# ---------------------------------------------------------
create_symlink() {
    local source_file="$1"
    local target_file="$2"

    # Ja mērķa fails eksistē un nav saite, uztaisām backup
    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
        echo "Backing up $target_file -> ${target_file}.backup"
        mv "$target_file" "${target_file}.backup"
    fi
    
    # Izveidojam direktoriju, ja tādas vēl nav
    mkdir -p "$(dirname "$target_file")"
    
    ln -sf "$source_file" "$target_file"
    echo "Symbolic link $target_file installed."
}

# 1. Sistēmas atjaunināšana
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# 2. Programmu instalēšana
echo "Installing packages..."

PACKAGES=(
    "zsh"
    "git"
    "vim"
    "gh"
    "curl"
    "wget"
    "btop"
    "neovim"
    "fzf"
    "eza"
    "build-essential"
    "python3"
    "python3-pip"
    "python3-venv"
)

sudo apt install -y "${PACKAGES[@]}"
echo "Packages installed successfully."

# 3. Dotfiles direktorijas sagatavošana (TAVI PIELĀGOTIE MAINĪGIE)
DOTFILES_DIR="$HOME/DOTFILES2DTVITOLS"
REPO_URL="https://github.com/gustavsvi/DOTFILES2DTVITOLS.git"

if [ -d "$DOTFILES_DIR" ]; then
    echo "📂 Updating dotfiles..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    echo "📥 Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 4. Oh My Zsh instalācija (Ja vēl nav uzstādīts)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Izveidojam custom mapes spraudņiem un motīviem
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins"
mkdir -p "$ZSH_CUSTOM/themes"

# Spraudņu (Plugins) lejupielāde
echo "Installing Plugins for Zsh..."

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "   Downloading zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "   ✅ zsh-autosuggestions already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "   Downloading zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "   ✅ zsh-syntax-highlighting already installed."
fi

# Powerlevel10k vizuālā motīva lejupielāde
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Downloading Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "✅ Powerlevel10k already installed."
fi

# 5. Simbolisko saišu (Symlinks) izveide
echo "Creating symbolic links..."

if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
else
    echo "⚠️ Warning: $DOTFILES_DIR/.zshrc not found in repository. Skipping symlink."
fi

# 6. Noklusējuma termināļa čaulas maiņa uz Zsh
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "🔄 Changing default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
fi

echo "=== setup.sh completed successfully! ==="
echo "Please restart your terminal to apply the changes."
