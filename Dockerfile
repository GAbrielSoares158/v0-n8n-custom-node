FROM node:22-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci

# Copiar código fonte
COPY src/ ./src/

# Build do Custom Node
RUN npm run build

# Criando a estrutura do diretório de saída
RUN mkdir -p /output/nodes /output/credentials

# Copiar arquivos compilados para saída
RUN cp -r dist/* /output/
RUN cp package.json /output/

VOLUME ["/output"]

CMD ["npm", "run", "build"]
