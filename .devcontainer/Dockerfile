FROM mcr.microsoft.com/devcontainers/base:jammy

# Install Node.js
ARG NODEJS_URL=https://nodejs.org/dist/v24.14.0/node-v24.14.0-linux-x64.tar.xz
RUN curl -fsSL $NODEJS_URL -o node.tar.xz \
    && tar -xf node.tar.xz -C /usr/local --strip-components=1 --no-same-owner \
    && rm node.tar.xz

# Install dependencies for claude sandboxing
RUN apt-get update && apt-get install -y \
    bubblewrap \
    socat
RUN npm install -g @anthropic-ai/sandbox-runtime

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY --from=ghcr.io/astral-sh/uv:latest /uvx /usr/local/bin/uvx

# Install GitHub CLI
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

USER vscode

# Install pnpm (as vscode user so it's on vscode's PATH)
RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
