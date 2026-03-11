#!/bin/bash

set -e

INSTALL_DIR="$HOME/.local/share/aquiny"

# Colors
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

header() {
    echo ""
    echo -e "${CYAN}${BOLD}  ╔══════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}  ║           aquiny installer           ║${RESET}"
    echo -e "${CYAN}${BOLD}  ╚══════════════════════════════════════╝${RESET}"
    echo ""
}

step() {
    echo -e "  ${GREEN}${BOLD}[$1/$TOTAL]${RESET} $2"
}

info() {
    echo -e "  ${DIM}$1${RESET}"
}

warn() {
    echo -e "  ${YELLOW}${BOLD}!${RESET} ${YELLOW}$1${RESET}"
}

error() {
    echo -e "  ${RED}${BOLD}✗${RESET} ${RED}$1${RESET}"
}

success() {
    echo -e "  ${GREEN}${BOLD}✓${RESET} ${GREEN}$1${RESET}"
}

TOTAL=5

header

warn "Make sure you have ollama up and running"
warn "aquiny needs qwen2.5:7b model"
info "If not installed, run: ollama pull qwen2.5:7b"
echo ""

echo -e "  ${BOLD}This installer will:${RESET}"
echo -e "    1. Copy files to ${DIM}${INSTALL_DIR}${RESET}"
echo -e "    2. Create a Python 3.12 virtual environment"
echo -e "    3. Install kittenTTS 0.8.1"
echo -e "    4. Install the ${BOLD}aquiny${RESET} command to ${DIM}/usr/bin${RESET}"
echo ""

read -r -p "  Press Enter to continue or Ctrl+C to cancel ... "
echo ""

# Step 1
step 1 "Creating install directory"
mkdir -p "$INSTALL_DIR"
success "Created ${INSTALL_DIR}"

# Step 2
step 2 "Copying files"
cp aquiny.py "$INSTALL_DIR"
cp notify.sh "$INSTALL_DIR"
cp LICENSE "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/notify.sh"
success "Copied aquiny.py, notify.sh, LICENSE"

# Step 3
step 3 "Setting up Python 3.12 virtual environment"
if ! command -v python3.12 &>/dev/null; then
    error "python3.12 not found. Please install Python 3.12 first."
    exit 1
fi
python3.12 -m venv "$INSTALL_DIR/.venv"
success "Virtual environment created"

# Step 4
step 4 "Installing kittenTTS"
"$INSTALL_DIR/.venv/bin/pip" install -q \
    https://github.com/KittenML/KittenTTS/releases/download/0.8.1/kittentts-0.8.1-py3-none-any.whl
success "kittenTTS 0.8.1 installed"

# Step 5
step 5 "Installing aquiny command"
info "Requires sudo to copy to /usr/bin"
sudo cp aquiny /usr/bin/aquiny
sudo chmod +x /usr/bin/aquiny
success "Installed /usr/bin/aquiny"

echo ""
echo -e "  ${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${GREEN}${BOLD}  aquiny installed successfully!${RESET}"
echo -e "  ${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${BOLD}Example:${RESET} aquiny \"Remind me to call Arham at 2 PM Today\""
echo ""
