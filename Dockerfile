# Build stage
FROM node:18-alpine

# Add non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change working directory
WORKDIR /app

# Copy package files first to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm install && \
    # Clean npm cache to reduce image size
    npm cache clean --force

# Copy application files and set correct ownership
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
