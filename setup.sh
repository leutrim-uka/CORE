#!/bin/bash

# Try to connect to the server with retries
for i in {1..5}; do
    if curl -fsSL http://localhost:11434 > /dev/null; then
        echo "Ollama server is up!"
        break
    else
        echo "Waiting for Ollama server..."
        sleep 5
    fi
done

# Install the model and run the Python script
echo "Installing the model"

# Install the llama2 model
curl -s -o /dev/null -X POST -H "Content-Type: application/json" -d '{"name":"mistral"}' http://localhost:11434/api/pull

echo "Installed the model"

python3 ./processing/main.py
