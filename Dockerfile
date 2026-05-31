ARG DEBIAN_TAG=bookworm-slim
FROM debian:${DEBIAN_TAG}

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    wget \
    unzip \
    build-essential \
    cmake \
    pkg-config \
    qt5-qmake \
    qtbase5-dev \
    qtbase5-dev-tools \
    qtmultimedia5-dev \
    libqt5svg5-dev \
    libqt5sql5-sqlite \
    leela-zero \
    clinfo \
    ocl-icd-libopencl1 \
    ocl-icd-opencl-dev \
    opencl-headers \
    zlib1g-dev \
    libzip-dev \
    libgomp1 \
    xauth \
    pandoc \
 && rm -rf /var/lib/apt/lists/*

# Build q5Go
WORKDIR /src/q5go

RUN git clone --depth=1 https://github.com/bernds/q5go.git . \
 && mkdir build \
 && cd build \
 && qmake ../src/q5go.pro PREFIX=/opt/q5go \
 && make -j"$(nproc)" \
 && make install

# Build KataGo from source, OpenCL backend
ARG KATAGO_VERSION=v1.16.4

WORKDIR /src

RUN git clone --depth=1 --branch ${KATAGO_VERSION} https://github.com/lightvector/KataGo.git katago-src \
 && cd katago-src/cpp \
 && cmake . \
      -DUSE_BACKEND=OPENCL \
      -DNO_GIT_REVISION=0 \
      -DNO_LIBZIP=0 \
 && make -j"$(nproc)" \
 && mkdir -p /opt/katago/models /opt/katago/configs \
 && cp katago /opt/katago/katago \
 && cp -r configs/* /opt/katago/configs/ \
 && ln -sf /opt/katago/katago /usr/local/bin/katago

ENV PATH="/opt/q5go/bin:/opt/katago:${PATH}"

CMD ["/opt/q5go/bin/q5go"]
