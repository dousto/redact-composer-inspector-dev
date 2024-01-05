VERSION --use-function-keyword 0.7

FROM alpine/git:2.43.0

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
            redact-composer-inspector/package-lock.json \
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
    SAVE ARTIFACT $copy_dir/package-lock.json
    SAVE ARTIFACT $copy_dir/tsconfig.json

# build-site Builds the web export of the app. To output the web-build artifacts, use: `earthly -a +build-site/\* .`
#     ARGS: --homepage  Optional replacement for the package.json "homepage" value. (default: package.json value)
#           --repo      The git repo for the build's source files. Can be 'local' or an SSH git url. (default: 'local')
#           --branch    The branch to use with `--repo`. No effect if `--repo=local`. (default: 'main')
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

# dev-deploy-ghp-site Builds and deploys the GitHub Pages site at https://dousto.github.io/redact-composer-inspector-dev.
#                     Deployment uses a forwarded SSH socket so will only work if you can locally `git push` via SSH.
#     ARGS: --repo    The git repo for the build's source files. Can be 'local' or an SSH git url. (default: 'local')
#           --branch  The branch to use with `--repo`. No effect if `--repo=local`. (default: 'main')
dev-deploy-ghp-site:
    FROM +ssh-init

    ARG repo="local"
    ARG branch="main"

    ENV ghp_repo="git@github.com:dousto/redact-composer-inspector-dev.git"
    ENV ghp_branch="website"
    ENV homepage="/redact-composer-inspector-dev/"

    DO +PREPARE_DEPLOYMENT_COMMIT \
        --repo=$repo --branch=$branch \
        --homepage=$homepage \
        --ghp_repo=$ghp_repo --ghp_branch=$ghp_branch

    DO +PUSH_DEPLOYMENT_COMMIT \
        --ghp_repo=$ghp_repo --ghp_branch=$ghp_branch

# deploy-ghp-site Builds and deploys the GitHub Pages site at https://dousto.github.io/redact-composer-inspector.
#                 For safety the build source is fixed to the latest commit of https://github.com/dousto/redact-composer-inspector/tree/main.
#                 Deployment uses a forwarded SSH socket so will only work if you can locally `git push` via SSH.
deploy-ghp-site:
    FROM +ssh-init

    ENV repo="git@github.com:dousto/redact-composer-inspector.git"
    ENV branch="main"
    ENV ghp_repo=$repo
    ENV ghp_branch="website"
    ENV homepage="/redact-composer-inspector/"

    DO +PREPARE_DEPLOYMENT_COMMIT \
        --repo=$repo --branch=$branch \
        --homepage=$homepage \
        --ghp_repo=$ghp_repo --ghp_branch=$ghp_branch

    DO +PUSH_DEPLOYMENT_COMMIT \
        --ghp_repo=$ghp_repo --ghp_branch=$ghp_branch

PREPARE_DEPLOYMENT_COMMIT:
    FUNCTION
    ARG repo
    ARG branch
    ARG ghp_repo
    ARG ghp_branch
    ARG homepage

    WORKDIR ghp-deploy
    GIT CLONE --branch $ghp_branch $ghp_repo website-branch
    RUN git -C ./website-branch checkout $ghp_branch
    # Clear the old website files
    RUN rm -rf website-branch/*
    # Copy the new website build files (with custom homepage for proper react navigation behavior)
    COPY (+build-site/web-build --homepage=$homepage --repo=$repo --branch=$branch) new-build
    RUN mv new-build/* website-branch/
    # React routing hack for GHP -- serve index.html in case of 404
    RUN cp website-branch/index.html website-branch/404.html

    # Prepare the commit
    WORKDIR website-branch
    RUN git add .
    RUN git config user.email "ci"; git config user.name "ci";
    RUN --no-cache git remote -v | grep push
    RUN --no-cache git status
    RUN --no-cache git commit -m "Update"

PUSH_DEPLOYMENT_COMMIT:
    FUNCTION
    ARG ghp_repo
    ARG ghp_branch

    RUN --push --ssh git push --verbose origin HEAD:$ghp_branch

# Use the dev container DOCKERFILE for build consistency.
expo:
    FROM DOCKERFILE .

expo-jq:
    FROM +expo

    RUN apt-get update && apt-get install -y jq ; \
        apt-get autoremove -y

ssh-init:
    RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
