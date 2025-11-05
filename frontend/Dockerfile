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
