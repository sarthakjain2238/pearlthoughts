# Use the official Node.js image as a base
FROM node:18

# Set the working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Medusa application
RUN npm run build

# Expose the port the app runs on
EXPOSE 7001

# Start the Medusa application
CMD ["npm", "start"]