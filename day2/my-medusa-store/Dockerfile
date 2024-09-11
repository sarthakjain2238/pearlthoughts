# Use an official Node.js runtime as a parent image 

FROM node:16-alpine 

 

# Set the working directory in the container 

WORKDIR /usr/src/app 

# Copy package.json and package-lock.json (if available) 

COPY package*.json ./ 

 

# Install dependencies 

RUN npm install 

 

# Copy the rest of the application code 

COPY . . 

 

# Expose the port Medusa runs on 

EXPOSE 7001

 

# Set environment variables if needed 

ENV NODE_ENV=production 

 

# Build the project (optional if there’s any build step) 

RUN npm run build 

 

# Start the Medusa server 

CMD ["npm", "run", "start"] 