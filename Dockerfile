FROM node:22-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY src/ ./src/

# Build the custom node
RUN npm run build

# Create the output directory structure
RUN mkdir -p /output/nodes /output/credentials

# Copy built files to output
RUN cp -r dist/* /output/
RUN cp package.json /output/

VOLUME ["/output"]

CMD ["npm", "run", "build"]
