FROM syedhassaanahmed/wix-node

RUN mkdir /home/wix/src
WORKDIR /home/wix/src
COPY --chown=wix . .

RUN npm install
RUN npm run dist:wine