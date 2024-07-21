# Use a CUDA-enabled base image
FROM nvidia/cuda:12.3.0-runtime-ubuntu22.04

# Set the environment variable to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and necessary packages
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y python3 
RUN apt-get install -y python3-pip

# Install Ollama (assuming there's an installation command)
RUN curl -fsSL https://ollama.com/install.sh | sh

# Copy your application code into the container
WORKDIR /app
COPY . /app

# Install application dependencies
RUN pip3 install -r requirements.txt

# Expose the port that Ollama server uses
EXPOSE 11434

RUN chmod +x setup.sh

# Run the Ollama server and your application
CMD ["sh", "-c", "ollama serve & sleep 10 && ./setup.sh"]
