FROM node:22.17-alpine3.22 AS builder
WORKDIR /app
COPY . /app
RUN sed -i 's#dl-cdn.alpinelinux.org#mirrors.tuna.tsinghua.edu.cn#g' /etc/apk/repositories && \
    apk update && apk add --no-cache android-tools gcc g++ make && \
    rm -rf /var/cache/apk/* && \
    npm config set registry https://registry.npmmirror.com && \
    npm install -g node-gyp && \
    npm install && npm run dist

FROM node:22.17-alpine3.22
WORKDIR /app
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
RUN sed -i 's#dl-cdn.alpinelinux.org#mirrors.tuna.tsinghua.edu.cn#g' /etc/apk/repositories && \
    apk update && apk add --no-cache android-tools bash tini && \
    rm -rf /var/cache/apk/*

EXPOSE 8000
CMD [ "/sbin/tini", "--", "node", "dist/index.js" ]