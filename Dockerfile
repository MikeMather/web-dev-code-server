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
    sqlite3 postgresql-client htop \
    docker.io docker-compose \
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

# Set Zsh as default shell
RUN chsh -s /bin/zsh

# Switch back to the default non-root user (coder)
USER coder

# Expose default code-server port
EXPOSE 8080

# Start code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080"]
