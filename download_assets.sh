#!/bin/bash

# Create directories if they don't exist
mkdir -p assets/sounds
mkdir -p assets/images

# Download sound effects
curl -L "https://freesound.org/data/previews/256/256012_4486188-lq.mp3" -o assets/sounds/keypress.wav
curl -L "https://freesound.org/data/previews/256/256013_4486188-lq.mp3" -o assets/sounds/return.wav
curl -L "https://freesound.org/data/previews/256/256014_4486188-lq.mp3" -o assets/sounds/ding.wav
curl -L "https://freesound.org/data/previews/256/256015_4486188-lq.mp3" -o assets/sounds/space.wav

# Download particle texture
curl -L "https://raw.githubusercontent.com/love2d/love/master/src/resources/particle.png" -o assets/images/particle.png

# Make the script executable
chmod +x download_assets.sh 