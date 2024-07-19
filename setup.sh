#!/bin/bash

echo "Installing the model"

# Install the llama2 model
curl -X POST -H "Content-Type: application/json" -d '{"name":"llama2"}' http://ollama-server-title-detection:11434/api/pull

echo "Installed the model"

python ./processing/main.py