FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:16

# NodeJS
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
    apt-get update -y && apt-get install -y gcc g++ make yarn

RUN node --version
RUN yarn --version