FROM almalinux/10-base:10.1

ARG NPROC=4
ARG HUL_COMMON_LIB_REF=main
ARG AMANEQ_SOFT_REF=main

RUN dnf -y update && \
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
      curl \
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
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN mkdir -p /opt/spadi/src /work

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

ENV PATH=/opt/spadi/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/spadi/lib64:/opt/spadi/lib:${LD_LIBRARY_PATH}

WORKDIR /work

CMD ["/bin/bash"]
