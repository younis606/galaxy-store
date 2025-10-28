FROM node:22
WORKDIR /app
COPY package*.json ./
RUN npm install --no-audit
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
