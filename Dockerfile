FROM ubuntu:20.04

ENV CODE_SERVER_VERSION 4.12.0
ENV APP_BIND_HOST 0.0.0.0
ENV DEBIAN_FRONTEND=noninteractive

# system libs
RUN apt update \
 && apt install \
    ca-certificates wget sudo dumb-init unzip fontconfig \
    htop locales git procps ssh vim curl lsb-release openssl\
    gcc build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget llvm xz-utils tk-dev liblzma-dev \
    python3-pip python3-distutils python3-apt -y

RUN apt update && \
    apt install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt update

# python
RUN apt install python3.10 python3.10-distutils python3.10-venv -y \
    && python3.10 -m ensurepip --upgrade

# vscode-server
RUN mkdir -p ~/.local/lib ~/.local/bin
RUN curl -sfL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz | tar -C ~/.local/lib -xz
RUN mv ~/.local/lib/code-server-${CODE_SERVER_VERSION}-linux-amd64 ~/.local/lib/code-server-${CODE_SERVER_VERSION}
RUN ln -s ~/.local/lib/code-server-${CODE_SERVER_VERSION}/bin/code-server ~/.local/bin/code-server
RUN PATH="~/.local/bin:$PATH"

# extensions
RUN curl -sfLO https://open-vsx.org/api/ms-toolsai/jupyter/2023.3.100/file/ms-toolsai.jupyter-2023.3.100.vsix \
 && curl -sfLO https://open-vsx.org/api/ms-python/python/2023.6.1/file/ms-python.python-2023.6.1.vsix \
 && curl -sfLO https://open-vsx.org/api/PKief/material-icon-theme/4.27.0/file/PKief.material-icon-theme-4.27.0.vsix \
 && curl -sfLO https://open-vsx.org/api/redhat/vscode-yaml/1.12.2/file/redhat.vscode-yaml-1.12.2.vsix \
 && curl -sfLO https://open-vsx.org/api/GitHub/vscode-pull-request-github/0.62.0/file/GitHub.vscode-pull-request-github-0.62.0.vsix \
 && curl -sfLO https://open-vsx.org/api/njpwerner/autodocstring/0.6.1/file/njpwerner.autodocstring-0.6.1.vsix \
 && curl -sfLO https://open-vsx.org/api/GrapeCity/gc-excelviewer/4.2.56/file/GrapeCity.gc-excelviewer-4.2.56.vsix \
 && curl -sfLO https://open-vsx.org/api/hediet/vscode-drawio/1.6.6/file/hediet.vscode-drawio-1.6.6.vsix \
 && curl -sfLO https://open-vsx.org/api/mtxr/sqltools-driver-pg/0.5.1/file/mtxr.sqltools-driver-pg-0.5.1.vsix \
 && curl -sfLO https://open-vsx.org/api/tonybaloney/vscode-pets/1.9.1/file/tonybaloney.vscode-pets-1.9.1.vsix \
 && ~/.local/bin/code-server --install-extension ./ms-toolsai.jupyter-2023.3.100.vsix || true \
 && ~/.local/bin/code-server --install-extension ./ms-python.python-2023.6.1.vsix || true \
 && ~/.local/bin/code-server --install-extension ./PKief.material-icon-theme-4.27.0.vsix || true \
 && ~/.local/bin/code-server --install-extension ./GitHub.vscode-pull-request-github-0.62.0.vsix || true \
 && ~/.local/bin/code-server --install-extension ./redhat.vscode-yaml-1.12.2.vsix || true \
 && ~/.local/bin/code-server --install-extension ./njpwerner.autodocstring-0.6.1.vsix || true \
 && ~/.local/bin/code-server --install-extension ./GrapeCity.gc-excelviewer-4.2.56.vsix || true \
 && ~/.local/bin/code-server --install-extension ./hediet.vscode-drawio-1.6.6.vsix || true \
 && ~/.local/bin/code-server --install-extension ./mtxr.sqltools-driver-pg-0.5.1.vsix || true \
 && ~/.local/bin/code-server --install-extension ./tonybaloney.vscode-pets-1.9.1.vsix || true \
 && rm ms-toolsai.jupyter-2023.3.100.vsix \
 && rm ms-python.python-2023.6.1.vsix \
 && rm PKief.material-icon-theme-4.27.0.vsix \
 && rm redhat.vscode-yaml-1.12.2.vsix \
 && rm GitHub.vscode-pull-request-github-0.62.0.vsix \
 && rm njpwerner.autodocstring-0.6.1.vsix \
 && rm GrapeCity.gc-excelviewer-4.2.56.vsix \
 && rm hediet.vscode-drawio-1.6.6.vsix \
 && rm mtxr.sqltools-driver-pg-0.5.1.vsix \
 && rm tonybaloney.vscode-pets-1.9.1.vsix

COPY settings.json /root/.local/share/code-server/User/

# python libs
COPY requirements.txt .
RUN  python3.10 -m pip install --upgrade pip setuptools \
    && python3.10 -m pip install psycopg2-binary \
    && python3.10 -m pip install -r requirements.txt \
    --extra-index-url https://art.lmru.tech/artifactory/api/pypi/pypi-local-dataplatform/simple \
    --extra-index-url https://art.lmru.tech/artifactory/api/pypi/pypi-local-sf/simple \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base \
        ~/.cache/pip

# zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -p git \
    -p history \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/zsh-users/zsh-completions \
    -t agnoster

# fonts
RUN apt install fonts-powerline

RUN mkdir ~/code

ENTRYPOINT [ "/bin/sh", "-c", "exec ~/.local/bin/code-server --host ${APP_BIND_HOST} ~/code"]