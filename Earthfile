VERSION 0.7

FROM alpine/git:2.43.0

build-site:
    ARG homepage

    FROM +expo-jq
    WORKDIR source-files
    COPY --dir +source-files/ .

    # Modify the package.json homepage if needed
    IF [ $homepage != "" ]
        RUN tmp=$(mktemp) && jq ".homepage = \"$homepage\"" package.json > "$tmp" && mv "$tmp" package.json
    END

    RUN npm install
    RUN npx expo export:web
    SAVE ARTIFACT web-build

source-files:
    ARG repo = "local"
    ARG branch = "main"
    
    ENV copy_dir = "source-files"
    IF [ $repo = "local" ]
        # Individually named for a faster to copy
        COPY --dir \
            redact-composer-inspector/src \
            redact-composer-inspector/assets \
            redact-composer-inspector/app.json \
            redact-composer-inspector/App.tsx \
            redact-composer-inspector/babel.config.js \
            redact-composer-inspector/package.json \
            redact-composer-inspector/tsconfig.json \
            $copy_dir
    ELSE
        GIT CLONE --branch $branch $repo $copy_dir
    END
    
    SAVE ARTIFACT $copy_dir/src
    SAVE ARTIFACT $copy_dir/assets
    SAVE ARTIFACT $copy_dir/app.json
    SAVE ARTIFACT $copy_dir/App.tsx
    SAVE ARTIFACT $copy_dir/babel.config.js
    SAVE ARTIFACT $copy_dir/package.json
    SAVE ARTIFACT $copy_dir/tsconfig.json

deploy-ghp-site:
    # This url format is compatible with the final git push
    ENV repo="ssh://git@github.com/dousto/redact-composer-inspector"
    ENV ghp_branch="website"
    ENV homepage="/redact-composer-inspector/"

    WORKDIR ghp-deploy
    GIT CLONE --branch $ghp_branch $repo website-branch
    # Clear the old website files
    RUN rm -r website-branch/*
    # Copy the new website build files (with custom homepage for proper react navigation behavior)
    COPY (+build-site/web-build --homepage=$homepage --repo=$repo --branch=main) new-build
    RUN mv new-build/* website-branch/
    # React routing hack for GHP -- serve index.html in case of 404
    RUN cp website-branch/index.html website-branch/404.html

    # Prepare for commit and push (if --push)
    WORKDIR website-branch
    RUN git add .
    RUN --no-cache git status
    RUN --push git config user.email "ci"; git config user.name "ci";
    RUN --push git commit -m "Update"
    RUN --push mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
    RUN --push --ssh git push --verbose $repo HEAD:refs/heads/$ghp_branch

expo:
    FROM DOCKERFILE .

expo-jq:
    FROM +expo

    RUN apt-get update && apt-get install -y jq ; \
        apt-get autoremove -y
