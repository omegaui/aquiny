#!/bin/bash
echo "🎯 Make sure you have ollama up and running"
echo "🎯 aquiny needs qwen2.5:7b model, if not installed install with \"ollama pull qwen2.5:7b\""
echo ""
echo "This installer does the following:"
echo "1. Creates ~/.local/share/aquiny"
echo "2. Copies aquiny.py, notify.sh and LICENSE to ~/.local/share/aquiny"
echo "3. Makes notify.sh executable"
echo "4. Changes directory to ~/.local/share/aquiny"
echo "5. Creates a python virtual environment with python3.12 (prerequisite)"
echo "6. Installs kittenTTS 0.8.1 model"
echo "7. Copies aquiny (shell script) to /usr/bin/aquiny"

mkdir -p "$HOME/.local/share/aquiny"
cp aquiny.py "$HOME/.local/share/aquiny" 
cp notify.sh "$HOME/.local/share/aquiny" 
cp LICENSE "$HOME/.local/share/aquiny" 

chmod +x "$HOME/.local/share/aquiny/notify.sh" 

cd "$HOME/.local/share/aquiny"

echo "Aquiny needs python 3.12 to run make sure it's installed!"

echo "Creating python3.12 virtual environment (using python3.12 as binary) ..."
python3.12 -m venv .venv

echo "Installing kittenTTS package ..."
./.venv/bin/pip install https://github.com/KittenML/KittenTTS/releases/download/0.8.1/kittentts-0.8.1-py3-none-any.whl

cd -
echo "Creating executable (need sudo permission to create /usr/bin/aquiny) ..."
sudo cp aquiny /usr/bin/aquiny
sudo chmod +x /usr/bin/aquiny
echo "Aquiny is now installed!"
echo "Example: aquiny \"Remind me to call Arham at 2 PM Today\""