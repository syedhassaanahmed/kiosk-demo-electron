FROM syedhassaanahmed/wix-node

RUN mkdir /home/wix/src
WORKDIR /home/wix/src
COPY . .

RUN npm install
RUN npm run dist:wine