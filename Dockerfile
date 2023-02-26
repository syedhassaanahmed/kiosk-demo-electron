FROM ghcr.io/syedhassaanahmed/node-wine:main

WORKDIR /kioskapp
COPY . .

RUN npm install
RUN npm run dist:wine