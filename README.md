

https://github.com/user-attachments/assets/7e0a18fa-cf4d-43dd-9a80-b8c8bdc102a0



The above example is running on a laptop with intel i5 CPU, NO GPU.
If you have a GPU then performance will be exponentially faster.

![Python](https://img.shields.io/badge/python-3.12-blue?logo=python&logoColor=white)
![Ollama](https://img.shields.io/badge/ollama-qwen2.5:7b-purple?logo=ollama&logoColor=white)
![TTS](https://img.shields.io/badge/TTS-KittenTTS_0.8-orange)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey?logo=linux&logoColor=white)
![License](https://img.shields.io/github/license/omegaui/aquiny)

# aquiny

A CLI assistant that schedules voice-based desktop notifications using natural language.

```
aquiny "remind me to take a break in 30 minutes"
```

aquiny parses your prompt with a local LLM (Qwen 2.5 via Ollama), generates a spoken message with KittenTTS, and schedules a desktop notification with audio playback at the right time using systemd timers.

## How it works

1. Your natural language prompt is sent to **Qwen 2.5:7b** running locally on Ollama
2. The LLM extracts a structured reminder (title, message, datetime)
3. **KittenTTS** generates a `.wav` voice file from the message
4. A **systemd user timer** is created to fire at the scheduled time
5. When triggered, `notify-send` shows a desktop notification and `aplay` plays the voice

## Prerequisites

- **Python 3.12**
- **Ollama** running locally with the `qwen2.5:7b` model pulled
- **Linux** with systemd, `notify-send`, and `aplay`

## Installation

```bash
ollama pull qwen2.5:7b
git clone https://github.com/omegaui/aquiny.git
cd aquiny
./installer.sh
```

The installer will:
- Copy files to `~/.local/share/aquiny`
- Create a Python 3.12 virtual environment
- Install KittenTTS
- Place the `aquiny` executable in `/usr/bin` (requires sudo)

## Customization

> **Important:** Open `aquiny.py` and change the `user_name` on **line 107** to your own name.
>
> ```python
> structured_data = parse_reminder("Arham", args.prompt)  # <-- change "Arham" to your name
> ```
>
> This name is used by the LLM to generate personalized notification messages (e.g. *"hey YourName, it's time to rest"*).

## Usage

```bash
aquiny "remind me to call Arham at 2 PM today"
aquiny "take a break in 45 minutes"
aquiny "stand up and stretch at 5:30 PM"
```

## License

[BSD 3-Clause](LICENSE)
