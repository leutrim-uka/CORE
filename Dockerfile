# Use an official Python 3.12 runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt ./

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install wget for downloading the fastText model
RUN apt-get update && apt-get install -y wget curl

# Copy the current directory contents into the container at /app
COPY . /app

# Install and start the Ollama server
RUN curl -fsSL https://ollama.com/install.sh | sh
RUN ollama pull mistral

# Expose the port the Ollama server runs on
EXPOSE 4000

# Define environment variables
ENV PYTHONPATH "${PYTHONPATH}:/app"

# Run main.py when the container launches
CMD ["python", "/app/processing/main.py"]
