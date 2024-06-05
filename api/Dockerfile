FROM node
WORKDIR /usr/src/app/api
COPY package*.json ./
RUN npm install
COPY . .
ENV PORT=8000
EXPOSE ${PORT}
CMD ["npm", "start"]