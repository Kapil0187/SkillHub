# # Use Node 22 base image
# FROM node:22.21.1

# # Set working directory
# WORKDIR /app

# # Copy package.json and package-lock.json or npm-shrinkwrap.json
# COPY frontend/package.json frontend/package-lock.json ./

# # Install dependencies
# RUN npm install

# # Copy remaining source code
# COPY frontend/ ./

# # Expose Vite default port
# EXPOSE 5173

# # Command to run dev server using npm
# CMD ["npm", "run", "dev"]


# frontend/Dockerfile
FROM node:22-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy all source files
COPY . .

# Build the app for production
RUN npm run build

# Expose port (Vite default: 5173)
EXPOSE 5173

# Start the development server
CMD ["npm", "run", "dev", "--", "--host"]
