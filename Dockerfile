FROM ubuntu:24.04

ARG TARGETOS
ARG TARGETARCH

ENV LANG="C.UTF-8"
ENV HOME=/home/codex
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p "$HOME"

### BASE ###

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binutils=2.42-* \
        sudo=1.9.* \
        build-essential=12.10* \
        bzr=2.7.* \
        curl=8.5.* \
        default-libmysqlclient-dev=1.1.* \
        dnsutils=1:9.18.* \
        fd-find=9.0.* \
        gettext=0.21-* \
        git=1:2.43.* \
        git-lfs=3.4.* \
        gnupg=2.4.* \
        inotify-tools=3.22.* \
        iputils-ping=3:20240117-* \
        jq=1.7.* \
        libbz2-dev=1.0.* \
        libc6=2.39-* \
        libc6-dev=2.39-* \
        libcurl4-openssl-dev=8.5.* \
        libdb-dev=1:5.3.* \
        libedit2=3.1-* \
        libffi-dev=3.4.* \
        libgcc-13-dev=13.3.* \
        libgdbm-compat-dev=1.23-* \
        libgdbm-dev=1.23-* \
        libgdiplus=6.1+dfsg-* \
        libgssapi-krb5-2=1.20.* \
        liblzma-dev=5.6.* \
        libncurses-dev=6.4+20240113-* \
        libnss3-dev=2:3.98-* \
        libpq-dev=16.11-* \
        libpsl-dev=0.21.* \
        libpython3-dev=3.12.* \
        libreadline-dev=8.2-* \
        libsqlite3-dev=3.45.* \
        libssl-dev=3.0.* \
        libstdc++-13-dev=13.3.* \
        libunwind8=1.6.* \
        libuuid1=2.39.* \
        libxml2-dev=2.9.* \
        libz3-dev=4.8.* \
        make=4.3-* \
        moreutils=0.69-* \
        netcat-openbsd=1.226-* \
        openssh-client=1:9.6p1-* \
        pkg-config=1.8.* \
        protobuf-compiler=3.21.* \
        ripgrep=14.1.* \
        rsync=3.2.* \
        software-properties-common=0.99.* \
        sqlite3=3.45.* \
        swig3.0=3.0.* \
        tk-dev=8.6.* \
        tzdata=2025b-* \
        universal-ctags=5.9.* \
        unixodbc-dev=2.3.* \
        unzip=6.0-* \
        uuid-dev=2.39.* \
        wget=1.21.* \
        xz-utils=5.6.* \
        zip=3.0-* \
        zlib1g=1:1.3.* \
        zlib1g-dev=1:1.3.* \
    && rm -rf /var/lib/apt/lists/*

### MISE ###

RUN install -dm 0755 /etc/apt/keyrings \
    && curl -fsSL https://mise.jdx.dev/gpg-key.pub | gpg --batch --yes --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg \
    && chmod 0644 /etc/apt/keyrings/mise-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg] https://mise.jdx.dev/deb stable main" > /etc/apt/sources.list.d/mise.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mise/stable \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'eval "$(mise activate bash)"' >> /etc/profile \
    && mise settings set experimental true \
    && mise settings set override_tool_versions_filenames none \
    && mise settings add idiomatic_version_file_enable_tools "[]"

ENV PATH=$HOME/.local/share/mise/shims:$PATH

### LLVM ###

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake=3.28.* \
        ccache=4.9.* \
        ninja-build=1.11.* \
        nasm=2.16.* \
        yasm=1.3.* \
        gawk=1:5.2.* \
        lsb-release=12.0-* \
    && rm -rf /var/lib/apt/lists/* \
    && bash -c "$(curl -fsSL https://apt.llvm.org/llvm.sh)"

### PYTHON ###

ARG PYENV_VERSION=v2.6.10
ARG PYTHON_VERSIONS="3.11.12 3.10 3.12 3.13 3.14"

# Install pyenv
ENV PYENV_ROOT=$HOME/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH
RUN git -c advice.detachedHead=0 clone --branch "$PYENV_VERSION" --depth 1 https://github.com/pyenv/pyenv.git "$PYENV_ROOT" \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /etc/profile \
    && echo 'export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"' >> /etc/profile \
    && echo 'eval "$(pyenv init - bash)"' >> /etc/profile \
    && cd "$PYENV_ROOT" \
    && src/configure \
    && make -C src \
    && pyenv install $PYTHON_VERSIONS \
    && pyenv global "${PYTHON_VERSIONS%% *}" \
    && rm -rf "$PYENV_ROOT/cache"

# Install pipx for common global package managers (e.g. poetry)
ENV PIPX_BIN_DIR=$HOME/.local/bin
ENV PATH=$PIPX_BIN_DIR:$PATH
RUN apt-get update \
    && apt-get install -y --no-install-recommends pipx=1.4.* \
    && rm -rf /var/lib/apt/lists/* \
    && pipx install --pip-args="--no-cache-dir --no-compile" poetry==2.1.* uv==0.7.* \
    && for pyv in "${PYENV_ROOT}/versions/"*; do \
         "$pyv/bin/python" -m pip install --no-cache-dir --no-compile --upgrade pip && \
         "$pyv/bin/pip" install --no-cache-dir --no-compile ruff black mypy pyright isort pytest; \
       done \
    && rm -rf "$HOME/.cache/pip" "$HOME/.cache/pipx"
    
# Reduce the verbosity of uv - impacts performance of stdout buffering
ENV UV_NO_PROGRESS=1

### NODE ###

ARG NVM_VERSION=v0.40.2
ARG NODE_VERSION=22

ENV NVM_DIR=$HOME/.nvm
# Corepack tries to do too much - disable some of its features:
# https://github.com/nodejs/corepack/blob/main/README.md
ENV COREPACK_DEFAULT_TO_LATEST=0
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
ENV COREPACK_ENABLE_AUTO_PIN=0
ENV COREPACK_ENABLE_STRICT=0
ENV NODE_PATH=/opt/codex/npm/node_modules

RUN git -c advice.detachedHead=0 clone --branch "$NVM_VERSION" --depth 1 https://github.com/nvm-sh/nvm.git "$NVM_DIR" \
    && echo 'source $NVM_DIR/nvm.sh' >> /etc/profile \
    && echo "prettier\neslint\ntypescript" > $NVM_DIR/default-packages \
    && . $NVM_DIR/nvm.sh \
    # The latest versions of npm aren't supported on node 18, so we install each set differently
    && nvm install 18 && nvm use 18 && npm install -g npm@10.9 pnpm@10.12 && corepack enable && corepack install -g yarn \
    && nvm install 20 && nvm use 20 && npm install -g npm@11.4 pnpm@10.12 && corepack enable && corepack install -g yarn \
    && nvm install 22 && nvm use 22 && npm install -g npm@11.4 pnpm@10.12 && corepack enable && corepack install -g yarn \
    && nvm install 24 && nvm use 24 && npm install -g npm@11.4 pnpm@10.12 && corepack enable && corepack install -g yarn \
    && nvm alias default "$NODE_VERSION" \
    && nvm cache clear \
    && npm cache clean --force || true \
    && pnpm store prune || true \
    && yarn cache clean || true

RUN . $NVM_DIR/nvm.sh \
    && nvm use "$NODE_VERSION" \
    && install_root=/opt/codex/npm \
    && mkdir -p "$install_root" \
    && cd "$install_root" \
    && npm install @openai/codex \
    && npm cache clean --force || true

### BUN ###

ARG BUN_VERSION=1.2.14
RUN mise use --global "bun@${BUN_VERSION}" \
    && mise cache clear || true \
    && rm -rf "$HOME/.cache/mise" "$HOME/.local/share/mise/downloads"

### JAVA ###

ARG GRADLE_VERSION=8.14
ARG MAVEN_VERSION=3.9.10
# OpenJDK 11 is not available for arm64. Codex Web only uses amd64 which
# does support 11.
ARG AMD_JAVA_VERSIONS="21 17 11"
ARG ARM_JAVA_VERSIONS="21 17"

RUN JAVA_VERSIONS="$( [ "$TARGETARCH" = "arm64" ] && echo "$ARM_JAVA_VERSIONS" || echo "$AMD_JAVA_VERSIONS" )" \
    && for v in $JAVA_VERSIONS; do mise install "java@${v}"; done \
    && mise install "gradle@${GRADLE_VERSION}" \
    && mise install "maven@${MAVEN_VERSION}" \
    && mise use --global "java@${JAVA_VERSIONS%% *}" \
    && mise use --global "gradle@${GRADLE_VERSION}" \
    && mise use --global "maven@${MAVEN_VERSION}" \
    && mise cache clear || true \
    && rm -rf "$HOME/.cache/mise" "$HOME/.local/share/mise/downloads"

### C++ ###
# gcc is already installed via apt-get above, so these are just additional linters, etc.
RUN pipx install --pip-args="--no-cache-dir --no-compile" cpplint==2.0.* clang-tidy==20.1.* clang-format==20.1.* cmakelang==0.6.* \
    && rm -rf "$HOME/.cache/pip" "$HOME/.cache/pipx"

### BAZEL ###

ARG BAZELISK_VERSION=v1.26.0

RUN curl -L --fail https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-${TARGETOS}-${TARGETARCH} -o /usr/local/bin/bazelisk \
    && chmod +x /usr/local/bin/bazelisk \
    && ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel

### GO ###

ARG GO_VERSIONS="1.25.1 1.24.3 1.23.8 1.22.12"
ARG GOLANG_CI_LINT_VERSION=2.1.6

# Go defaults GOROOT to /usr/local/go - we just need to update PATH
ENV PATH=/usr/local/go/bin:$HOME/go/bin:$PATH
RUN for v in $GO_VERSIONS; do mise install "go@${v}"; done \
    && mise use --global "go@${GO_VERSIONS%% *}" \
    && mise use --global "golangci-lint@${GOLANG_CI_LINT_VERSION}" \
    && mise cache clear || true \
    && rm -rf "$HOME/.cache/mise" "$HOME/.local/share/mise/downloads"

### ELIXIR ###

ARG ERLANG_VERSION=27.1.2
ARG ELIXIR_VERSION=1.18.3
RUN mise install "erlang@${ERLANG_VERSION}" "elixir@${ELIXIR_VERSION}-otp-27" \
    && mise use --global "erlang@${ERLANG_VERSION}" "elixir@${ELIXIR_VERSION}-otp-27" \
    && mise cache clear || true \
    && rm -rf "$HOME/.cache/mise" "$HOME/.local/share/mise/downloads"

### SETUP SCRIPTS ###

COPY setup_universal.sh /opt/codex/setup_universal.sh
RUN chmod +x /opt/codex/setup_universal.sh

### VERIFICATION SCRIPT ###

COPY verify.sh /opt/verify.sh
RUN chmod +x /opt/verify.sh && bash -lc "TARGETARCH=$TARGETARCH /opt/verify.sh"

### NON-ROOT USER ###

RUN set -eux; \
    CODENAME="codex"; \
    if getent group "$CODENAME" >/dev/null; then \
        true; \
    elif getent group 1000 >/dev/null; then \
        groupmod --new-name "$CODENAME" "$(getent group 1000 | cut -d: -f1)"; \
    else \
        groupadd --gid 1000 "$CODENAME"; \
    fi; \
    if id -u "$CODENAME" >/dev/null 2>&1; then \
        usermod --home /home/codex --shell /bin/bash "$CODENAME"; \
    elif getent passwd 1000 >/dev/null; then \
        usermod --login "$CODENAME" --home /home/codex --shell /bin/bash "$(getent passwd 1000 | cut -d: -f1)"; \
    else \
        useradd --uid 1000 --gid "$CODENAME" --home-dir /home/codex --shell /bin/bash --no-create-home "$CODENAME"; \
    fi; \
    mkdir -p /home/codex; \
    chown -R "$CODENAME":"$CODENAME" /home/codex

### ENTRYPOINT ###

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

USER codex
WORKDIR /home/codex

ENTRYPOINT  ["/opt/entrypoint.sh"]
