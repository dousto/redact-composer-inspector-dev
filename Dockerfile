FROM node:18

RUN mkdir -p /root/redact-composer-inspector /root/.vscode-server/extensions

RUN npm install -g npm@latest
RUN npm install -g eslint typescript expo-cli @expo/ngrok@^4.1.0
RUN node --version && npm --version

CMD /bin/sh -c "while sleep 86000; do :; done"