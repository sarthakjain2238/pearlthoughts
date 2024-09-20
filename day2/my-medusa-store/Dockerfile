# Dockerfile for Medusa

# Use the official Node.js image as a base image
FROM node:16

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 9000 inside the container
EXPOSE 9000

# Command to run the Medusa server
CMD ["npm", "run", "start"]
