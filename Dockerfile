FROM almalinux:9

ARG NPROC=4
ARG HUL_COMMON_LIB_REF=main
ARG AMANEQ_SOFT_REF=main
ARG OPENFPGALOADER_REF=master
ARG SITCP_IP_UTILITY_REF=main

RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y install \
      gcc \
      gcc-c++ \
      make \
      cmake \
      git \
      emacs-nox \
      iproute \
      iputils \
      net-tools \
      bind-utils \
      traceroute \
      tcpdump \
      nmap-ncat \
      curl-minimal \
      wget \
      procps-ng \
      psmisc \
      lsof \
      which \
      less \
      vim-minimal \
      findutils \
      tar \
      gzip \
      pkgconf-pkg-config \
      libftdi-devel \
      libusbx-devel \
      hidapi-devel \
      libgpiod-devel \
      systemd-devel \
      zlib-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN mkdir -p /opt/spadi/src /workspace

WORKDIR /opt/spadi/src

RUN git clone https://github.com/spadi-alliance/hul-common-lib.git hul-common-lib && \
    cd hul-common-lib && \
    git checkout "${HUL_COMMON_LIB_REF}" && \
    cmake \
      -S . \
      -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/spadi && \
    cmake --build build -j"${NPROC}" && \
    cmake --install build

RUN git clone https://github.com/spadi-alliance/amaneq-soft.git amaneq-soft && \
    cd amaneq-soft && \
    git checkout "${AMANEQ_SOFT_REF}" && \
    cmake \
      -S . \
      -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/spadi \
      -DCMAKE_PREFIX_PATH=/opt/spadi && \
    cmake --build build -j"${NPROC}" && \
    cmake --install build

RUN git clone https://github.com/trabucayre/openFPGALoader.git openFPGALoader && \
    cd openFPGALoader && \
    git checkout "${OPENFPGALOADER_REF}" && \
    cmake \
      -S . \
      -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/spadi && \
    cmake --build build -j"${NPROC}" && \
    cmake --install build

RUN git clone https://github.com/nobukoba/sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial.git \
      sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial && \
    cd sitcp-sitcpxg-mpc-mpcx-ip-utility-first-trial && \
    git checkout "${SITCP_IP_UTILITY_REF}" && \
    make -j"${NPROC}" && \
    make PREFIX=/opt/spadi install

ENV PATH=/opt/spadi/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/spadi/lib64:/opt/spadi/lib

WORKDIR /workspace

CMD ["/bin/bash"]
