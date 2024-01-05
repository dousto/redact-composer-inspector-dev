Dev Workspace for [redact-composer-inspector](https://github.com/dousto/redact-composer-inspector), configured as a [VSCode dev container](https://code.visualstudio.com/docs/devcontainers/containers).

## Steps to get started
1. Clone this repo.
2. Clone [redact-composer-inspector](https://github.com/dousto/redact-composer-inspector) within this repo.
3. Make sure you have [VS Code dev containers](https://code.visualstudio.com/docs/devcontainers/tutorial) setup.
4. Open `.` in VS Code and choose to run the dev container.
5. From the container's terminal
    ```
    npm install
    npx expo start --tunnel
    ```

## Earthly
Earthly is used mainly for the GitHub Pages deployment.