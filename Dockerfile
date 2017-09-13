FROM syedhassaanahmed/wix-node

RUN mkdir /home/wix/src
COPY . /home/wix/src
WORKDIR /home/wix/src

RUN npm install
RUN npm run dist:wine