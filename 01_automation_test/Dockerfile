# Use the official image as a parent image.
FROM nginx:latest

# Set the working directory.
WORKDIR /home/ubuntu

# Copy the file from your host to your current location.
COPY ./index.html /usr/share/nginx/html

# Add metadata to the image to describe which port the container is listening on at runtime.
EXPOSE 80
