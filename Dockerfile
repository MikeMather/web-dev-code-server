# Use code-server base image
FROM codercom/code-server:latest

# Switch to root user to install system packages
USER root

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/zsh
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=20

# Create the NVM directory and set proper permissions
RUN mkdir -p $NVM_DIR && chown -R coder:coder $NVM_DIR

# Install essential packages

RUN apt-get update && apt-get install -y \
    curl wget zsh git build-essential python3 python3-pip python3-venv \
    python3-dev bzip2 openssl libssl-dev lzma \
    gcc libffi-dev libc-dev libsqlite3-dev zlib1g-dev libbz2-dev \ 
    libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev \
    sqlite3 postgresql-client htop \
    docker.io docker-compose \
    make build-essential libssl-dev zlib1g-dev \
    && apt-get clean

# Install Oh-My-Zsh for a better Zsh experience
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Install nvm, node, npm, and yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && npm install -g npm yarn webpack parcel-bundler vite eslint prettier
    

# Add nvm initialization to Zsh profile
RUN echo 'export NVM_DIR="/usr/local/nvm"' >> /home/coder/.zshrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/coder/.zshrc \
    && echo 'nvm use default' >> /home/coder/.zshrc

RUN curl https://pyenv.run | bash

RUN echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.zshrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.zshrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc


# Set Zsh as default shell
RUN chsh -s /bin/zsh

# Switch back to the default non-root user (coder)
USER coder

COPY ./ /usr/app
WORKDIR /usr/app

# VS Code extensions
RUN code-server --install-extension Catppuccin.catppuccin-vsc
RUN code-server --install-extension esbenp.prettier-vscode
RUN code-server --install-extension dbaeumer.vscode-eslint
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ./GH-Copilot.vsix

# Expose default code-server port
EXPOSE 8080

# Start code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080"]