FROM ubuntu@sha256:d26d529daa4d8567167181d9d569f2a85da3c5ecaf539cace2c6223355d69981
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y \
    emacs \
    git \
    build-essential \
    texinfo \
    bison \
    flex \
    autoconf \
    automake \
    curl \
    gperf \
    libtool \
    patchutils \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    gawk \
    file \
    zlib1g-dev \
    libssl-dev \
    ibglib2.0-dev \
    libpixman-1-dev \
    device-tree-compiler \
    autotools-dev \
    apt-utils wget \
    cpio \
    python \
    unzip \    
    bc \
    libncurses5-dev \
    expat \
    libexpat1-dev \
    qemu \
    g++ \
    rsync \
    readline-common \
    strace \
    remake \
    libusb-1.0-0-dev \
    pkg-config \
    libterm-readline-gnu-perl \
    xxd
ENV HOME /home/build
RUN useradd -m -s /bin/bash build
USER build
WORKDIR /home/build/
RUN git clone https://github.com/riscv/riscv-gnu-toolchain.git
WORKDIR /home/build/riscv-gnu-toolchain
RUN git checkout afcc8bc655d30cf6af054ac1d3f5f89d0627aa79 #latest working commit
RUN git submodule update --recursive --init
RUN ./configure --prefix=/home/build/riscv-toolchain
RUN make linux -j8
ENV PATH=$PATH:/home/build/riscv-toolchain/bin
WORKDIR /home/build/
RUN git clone https://github.com/mcd500/freedom-u-sdk.git
WORKDIR /home/build/freedom-u-sdk/
RUN git checkout 29fe529f8dd8e1974fe1743184b3e13ebb2a21dc
RUN git submodule update --recursive --init
WORKDIR /home/build/freedom-u-sdk/buildroot
RUN git checkout c4ddfe7a5fd964274c99033bd87df3dc7534d196 # "sifive" buildroot branch
WORKDIR /home/build/freedom-u-sdk/
RUN echo "BR2_PACKAGE_TREE=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo "BR2_PACKAGE_OPENSSL=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo "BR2_PACKAGE_OPENSSL_BIN=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo "BR2_PACKAGE_GNUPG2=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo "BR2_PACKAGE_SCREEN=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo "BR2_PACKAGE_NANO=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo "BR2_PACKAGE_GCC=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo "BR2_PACKAGE_HAVEGED=y" >> /home/build/freedom-u-sdk/conf/buildroot_initramfs_config
RUN echo ".PHONY: qemulite" >> /home/build/freedom-u-sdk/Makefile
RUN echo "qemulite: \$(qemu) \$(bbl) \$(rootfs)" >> /home/build/freedom-u-sdk/Makefile
RUN make  all qemulite -j8
RUN mkdir -p /home/build/compiled
RUN echo "cp /home/build/freedom-u-sdk/work/riscv-pk/bbl /home/build/compiled/" > /home/build/freedom-u-sdk/install.sh
RUN echo "cp /home/build/freedom-u-sdk/work/rootfs.bin /home/build/compiled/" >> /home/build/freedom-u-sdk/install.sh
RUN echo "cp /home/build/freedom-u-sdk/work/riscv-qemu/prefix/bin/qemu-system-riscv64 /home/build/compiled/" >> /home/build/freedom-u-sdk/install.sh










