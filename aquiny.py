# Goal: Build a cli assistant that can trigger voice based notifications.

import soundfile as sf
import json
import uuid
import requests
import argparse
import logging
from datetime import datetime
from kittentts import KittenTTS
import os
import subprocess
from datetime import datetime

logging.disable(logging.WARNING)

# Define cli
parser = argparse.ArgumentParser()
parser.add_argument("prompt")
args = parser.parse_args()

# Create Context
now = datetime.now().isoformat(timespec="seconds")

# function to call qwen to crunch prompt
def parse_reminder(user_name, prompt):
    prompt = f"""
You are a reminder parsing engine.

Your task:
Convert the user input into STRICT JSON.

Rules:
- Output ONLY valid JSON.
- Do NOT output explanations.
- Do NOT output markdown.
- Do NOT output code blocks.
- Do NOT output extra text.
- Do NOT wrap in quotes.
- JSON must be parseable by Python json.loads().
- If information is missing, set the field to null.
- If time is ambiguous, assume the next upcoming occurrence.
- Use 24-hour format.
- Use ISO 8601 datetime format: YYYY-MM-DDTHH:MM:SS

Schema:
{{
  "title": "short event title",
  "message": "a friendly message, to be spoken by assistant when notification is due. example: hey {user_name}, it's time to rest.",
  "datetime": "ISO8601 string",
  "confidence": number between 0 and 1
}}

Current datetime:
{now}

User name:
{user_name}

User input:
{prompt}

Return JSON only.
"""

    response = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "qwen2.5:7b",
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.1,
                "num_predict": 200
            }
        },
        timeout=60
    )

    response.raise_for_status()
    model_response = response.json()["response"].strip()

    # If model returned multiple JSON objects, we need to merge them into one
    decoder = json.JSONDecoder()
    objects = []
    pos = 0
    while pos < len(model_response):
        if model_response[pos] in ' \t\n\r':
            pos += 1
            continue
        obj, end = decoder.raw_decode(model_response, pos)
        objects.append(obj)
        pos = end

    if len(objects) == 1:
        return objects[0]

    combined = objects[0]
    for obj in objects[1:]:
        combined['title'] += " and " + obj['title']
        combined['message'] += " and " + obj['message']
    return combined


print("Generating notification content ...")
structured_data = parse_reminder("Arham", args.prompt)

# creating speech with kittenTTS
print("Generating notification voice ...")
m = KittenTTS("KittenML/kitten-tts-mini-0.8")
audio = m.generate(structured_data['message'], voice='Hugo', speed=1.2)

# assign an id to notification
notification_id = uuid.uuid4()
sf.write(f'{notification_id}.wav', audio, 24000)

# schedule the notification and playback
def schedule(args, isodatetime):
    dt = datetime.fromisoformat(isodatetime)
    timestamp = dt.strftime("%Y-%m-%d %H:%M:%S")

    env_vars = ["DISPLAY", "WAYLAND_DISPLAY", "DBUS_SESSION_BUS_ADDRESS"]
    env_flags = []
    for var in env_vars:
        val = os.environ.get(var)
        if val:
            env_flags += [f"--setenv={var}={val}"]

    subprocess.run(
        [
            "systemd-run", "--user", "--quiet",
            f"--on-calendar={timestamp}",
            f"--working-directory={os.getcwd()}",
            "--timer-property=AccuracySec=1s",
            *env_flags,
            "--",
            *args,
        ],
        check=True,
    )

schedule(['bash', 'notify.sh', f'{notification_id}', structured_data['title'], structured_data['message']], structured_data['datetime'])
print("Scheduled your notification, will trigger at", structured_data['datetime'])