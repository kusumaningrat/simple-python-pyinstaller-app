# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app/

# Install PyInstaller
RUN pip install pyinstaller

# Build the Python application using PyInstaller
RUN pyinstaller --onefile sources/add2vals.py

# Set the command to run your_script when the container starts
CMD ["./dist/your_script"]