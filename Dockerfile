FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

# For lab/demo: runs as HTTP server (no SQS needed)
# For production: change to worker.js (reads from SQS queue)
CMD ["node", "server.js"]
