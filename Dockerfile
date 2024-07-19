# Use an official Python 3.12 runtime as a parent image
FROM python:3.12

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

# Expose the port the Ollama server runs on
EXPOSE 11434

# Make script executable
RUN chmod +x setup.sh

# Run the setup script when the container launches
CMD ["sh", "./setup.sh"]
