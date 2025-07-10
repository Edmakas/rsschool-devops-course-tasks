# Use the official Python image as a base
FROM python:3.10-slim

# Set the working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# Set environment variable for Flask
ENV FLASK_APP=main.py

# Run the Flask app
CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"] 
