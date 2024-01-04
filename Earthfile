VERSION 0.7

FROM alpine/git:2.43.0

build-site:
    ARG homepage

    FROM +expo-jq
    WORKDIR source-files
    COPY --dir \
        redact-composer-inspector/src \
        redact-composer-inspector/assets \
        redact-composer-inspector/app.json \
        redact-composer-inspector/App.tsx \
        redact-composer-inspector/babel.config.js \
        redact-composer-inspector/package.json \
        redact-composer-inspector/tsconfig.json \
        .

    # Modify the package.json homepage if needed
    IF [ $homepage != "" ]
        RUN tmp=$(mktemp) && jq ".homepage = \"$homepage\"" package.json > "$tmp" && mv "$tmp" package.json
    END

    RUN npm install
    RUN npx expo export:web
    RUN cp web-build/index.html web-build/404.html # React routing hack for GHP
    SAVE ARTIFACT web-build

deploy-ghp-site:
    WORKDIR ghp-deploy
    GIT CLONE --branch website git@github.com:dousto/redact-composer-inspector.git website-branch
    RUN rm -r website-branch/*
    COPY (+build-site/web-build --homepage='/redact-composer-inspector/') new-build
    RUN mv new-build/* website-branch/
    RUN rm -r new-build
    WORKDIR website-branch
    RUN git add .
    RUN --no-cache git status
    RUN --push git config user.email "ci"; git config user.name "ci";
    RUN --push git commit -m "Update"
    RUN --push mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
    RUN --push --ssh git push --verbose ssh://git@github.com/dousto/redact-composer-inspector HEAD:refs/heads/website

expo:
    FROM node:18
    RUN npm install -g npm@latest
    RUN npm install -g eslint typescript expo-cli @expo/ngrok@^4.1.0
    RUN node --version && npm --version

expo-jq:
    FROM +expo

    RUN apt-get update && apt-get install -y jq ; \
        apt-get autoremove -y
