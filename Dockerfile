# syntax=docker/dockerfile:1
ARG GITHUB_TOKEN
# from docker-setup repo
FROM dev-env

# Make sure build‑time ARG is in scope
ARG GITHUB_TOKEN

# Switch to non‑root “dev” user (already created in dev‑env)
USER dev
WORKDIR /workspace

# Build & install standalone Asio 1.30.2
RUN git clone --branch asio-1-30-2 --single-branch \
        https://github.com/chriskohlhoff/asio.git /workspace/asio && \
    cd /workspace/asio/asio && \
    ./autogen.sh && \
    mkdir -p /workspace/build/asio && cd /workspace/build/asio && \
    /workspace/asio/asio/configure --prefix=/usr/local && \
    make -j$(nproc) && sudo make install && \
    rm -rf /workspace/asio

# --- Private dependency repos (requires secret 'gh') ---
# Build with:
#   DOCKER_BUILDKIT=1 docker build --secret id=gh,env=GITHUB_TOKEN -t my-image .
# Comment out this block if all deps are public.
RUN --mount=type=secret,id=gh,uid=1000,gid=1000,mode=0400,required \
    set -eux; GHTOKEN="$(cat /run/secrets/gh)"; \
    for repo in \
        a-cmake-library \
        the-macro-library \
        a-memory-library \
        the-lz4-library \
        the-io-library \
    ; do \
      git clone "https://${GHTOKEN}@github.com/knode-ai-open-source/${repo}.git" "$repo"; \
      (cd "$repo" && ./build_install.sh); \
      rm -rf "$repo"; \
    done

# 3) Clone Restinio fork and build fmt, expected-lite, then Restinio core
RUN git clone --branch v.0.7.3-fork --single-branch \
        https://github.com/andycurtis-public/restinio.git /workspace/restinio && \
    mkdir -p /workspace/build/fmt /workspace/build/expected-lite /workspace/build/restinio && \
    cd /workspace/build/fmt && \
      cmake /workspace/restinio/fmt && \
      make -j$(nproc) && sudo make install && \
    cd /workspace/build/expected-lite && \
      cmake /workspace/restinio/expected-lite && \
      make -j$(nproc) && sudo make install && \
    cd /workspace/build/restinio && \
      cmake /workspace/restinio/dev \
        -DRESTINIO_SAMPLE=OFF \
        -DRESTINIO_TEST=OFF \
        -DRESTINIO_DEP_FMT=system \
        -DRESTINIO_DEP_EXPECTED_LITE=system && \
      make -j$(nproc) && sudo make install && \
    rm -rf /workspace/restinio

# 4) Build & install your Restinio‑C wrapper
COPY . /workspace/restinio-c
RUN mkdir -p /workspace/build/restinio-c && \
    cd /workspace/build/restinio-c && \
    cmake /workspace/restinio-c && \
    make -j$(nproc) && sudo make install

# drop into a shell by default
CMD ["/bin/bash"]
