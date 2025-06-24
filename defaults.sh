#!/bin/bash

# ==============================================================================
# macOS Configuration Script V9 (Post-Brewfile)
#
# This script configures macOS for a developer after a Brewfile has been run.
# It sets up Git, SSH, system settings, keyboard shortcuts, and the Dock.
# It assumes tools like 'git', 'dockutil', and 'duti' are already installed.
# ==============================================================================

# --- Helper Functions ---
print_header() {
  echo ""
  echo "=============================================================================="
  echo "➡️  $1"
  echo "=============================================================================="
}

# --- Initial Setup ---
print_header "Starting macOS Configuration"
sudo -v # Ask for the administrator password upfront
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null & # Keep sudo session alive

# --- 1. Configure Git ---
print_header "Configuring Git"

# Set the default branch name for new repositories to 'main'
git config --global init.defaultBranch main

if [ -z "$(git config --global user.name)" ]; then
    echo "Git user name not set. Let's configure it."
    read -p "Enter your full name for Git commits: " git_name
    git config --global user.name "$git_name"
else
    echo "Git user name is already set to: $(git config --global user.name)"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "Git user email not set. Let's configure it."
    read -p "Enter your email for Git commits: " git_email
    git config --global user.email "$git_email"
else
    echo "Git user email is already set to: $(git config --global user.email)"
fi

# --- 2. Generate SSH Key ---
print_header "Checking for SSH Key"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "SSH key not found. Generating a new ed25519 key..."
    ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f "$SSH_KEY_PATH" -N ""
    echo "SSH key generated."
else
    echo "SSH key already exists. Skipping generation."
fi
echo ""
echo "------------------------------------------------------------------------------"
echo "✅ Your public SSH key is ready. Copy the line below to GitHub/GitLab:"
echo "------------------------------------------------------------------------------"
cat "${SSH_KEY_PATH}.pub"
echo "------------------------------------------------------------------------------"


# --- 3. System & Quality-of-Life Settings ---
print_header "Applying System, Finder & Quality-of-Life Tweaks"

# Finder: show path bar and all file extensions
defaults write com.apple.finder ShowPathbar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set screenshot location to a dedicated folder
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

# Disable smart quotes and dashes as they're annoying for coding
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Set TextEdit to default to plain text mode
defaults write com.apple.TextEdit RichText -int 0

# Tweak Activity Monitor to be more useful for developers
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor IconType -int 5 # Show CPU usage in the Dock icon
defaults write com.apple.ActivityMonitor ShowCategory -int 0 # Show all processes

# Other System Settings...
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
defaults write -g AppleAccentColor -int -2
defaults write com.apple.menuextra.clock "FlashDateSeparators" -bool "true"
defaults write com.apple.menuextra.clock "ShowDate" -int 2

# Dock & Mission Control behavior
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 64
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 32
defaults write com.apple.dock autohide -bool true


# --- 4. Default Applications & Keyboard Shortcuts ---
print_header "Setting Default Applications and Keyboard Shortcuts"
echo "Setting Brave Browser as default for web protocols..."
duti -s com.brave.Browser http; duti -s com.brave.Browser https; duti -s com.brave.Browser html
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 160 "{enabled = 1; value = { parameters = (100, 2, 1048576); type = 'standard'; }; }"


# --- 5. Configure the Dock ---
print_header "Configuring the Dock"
# This list is based on your request and Brewfile. Edit as needed.
APPS_TO_PIN=(
  "/Applications/Brave Browser.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/Warp.app"
  "/Applications/Fork.app"
  "/Applications/Notion.app"
)
FOLDER_TO_ADD="$HOME/Development"
mkdir -p "$FOLDER_TO_ADD"

dockutil --remove all --no-restart
for app_path in "${APPS_TO_PIN[@]}"; do
    if [ -d "$app_path" ]; then
        echo "      Adding '$app_path' to Dock"
        dockutil --add "$app_path" --no-restart
    else
        echo "      WARNING: Application not found at '$app_path'. It may not be installed."
    fi
done
echo "      Adding folder '$FOLDER_TO_ADD' to Dock"
dockutil --add "$FOLDER_TO_ADD" --displayas grid --no-restart


# --- 6. Finalizing Setup ---
print_header "Finalizing Setup"
killall Finder; killall Dock; killall SystemUIServer; killall TextEdit; killall Activity\ Monitor
echo ""
echo "✅ macOS configuration is complete! Note: Some changes may require a logout/restart to take full effect."
echo "💡 Your Brewfile installed great developer fonts. Don't forget to set 'JetBrains Mono Nerd Font' or 'Hack Nerd Font' in your terminal and code editor settings!"

# If it doesn't run you might need to run the below
# chmod +x defaults.sh

# Run the below to run the script
# ./defaults.sh


# Things to add
# - Remove Hints app or disable notifications
# - Remove Apps: GarageBand