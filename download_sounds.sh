#!/bin/bash

# Create sounds directory if it doesn't exist
mkdir -p assets/sounds

# Download verified typewriter sound effects
curl -L -o assets/sounds/keypress.wav "https://typewriter-sounds.s3.amazonaws.com/key.wav"
curl -L -o assets/sounds/return.wav "https://typewriter-sounds.s3.amazonaws.com/return.wav"
curl -L -o assets/sounds/space.wav "https://typewriter-sounds.s3.amazonaws.com/space.wav"
curl -L -o assets/sounds/backspace.wav "https://typewriter-sounds.s3.amazonaws.com/backspace.wav"
curl -L -o assets/sounds/ding.wav "https://typewriter-sounds.s3.amazonaws.com/ding.wav"

# Make executable
chmod +x download_sounds.sh 