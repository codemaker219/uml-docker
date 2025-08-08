FROM docker.io/ubuntu:24.04 as build

RUN apt-get update && apt-get install -y gcc make curl vim patch flex bison xz-utils bc libncurses-dev cpio kmod

ADD root/dependencies /dependencies

# You can run downloadDependencies.sh on the host to prefetch sources
RUN test -f /dependencies/linux.tar.xz || /dependencies/downloadDependencies.sh


##################
# build static linked slirp
##################
ADD root/slirp /slirp
RUN tar -xf /dependencies/slirp_1_0_17_patch.tar.gz \
    && tar -xf /dependencies/slirp-1.0.16.tar.gz \
    && cd slirp-1.0.16 \
    && sed -e 's|^--- src-o/|--- src/|' -e 's|^+++ src2/|+++ src/|' ../fix17.patch | patch -p0 \
    && cd src  \
    && sed -i '77,78 s/^/extern /'  options.c \
    && env CC="gcc -std=gnu89 -DFULL_BOLT -static -Wno-unused   -DUSE_PPP -DUSE_MS_DNS -fno-strict-aliasing  " LDFLAGS=-static  ./configure \
    && cd .. \
    && for p in /slirp/*.patch; do patch -p1 < "$p";  done \
    && make -C src

##################
# prepare the initram
##################
RUN mkdir /initram \
    && tar -C /initram -xf /dependencies/alpine-minirootfs.tar.gz \
    && cp /etc/resolv.conf /initram/etc/ \
    && chroot /initram /bin/sh -c 'apk add util-linux tmux dmesg vim curl e2fsprogs inetutils-telnet debootstrap zstd' \
    && mkdir -p /initram/usr/share/keyrings/ \
    && cp /usr/share/keyrings/ubuntu-archive-keyring.gpg /initram/usr/share/keyrings/ \
    && cp /slirp-1.0.16/src/slirp /initram/ \
    && printf "search localdomain\nnameserver 10.0.2.3\n" > /initram/etc/resolv.conf

##################
# compile kernel (fist time) without initam
##################
ADD root/kernel /kernel
RUN tar -xf /dependencies/linux.tar.xz \
    && cd  linux-* \
    && for p in /kernel/*.patch; do patch -p1 < "$p";  done \
    && cp /kernel/kernel_config .config \
    && make ARCH=um -j$(nproc) \
    && make INSTALL_MOD_PATH=/initram modules_install

##################
#finialize initram
##################
ADD root/initram /initram
ADD root/gen_initramfs_list.sh /
RUN /gen_initramfs_list.sh /initram > /initram.txt \
    && echo "nod /dev/console 0600 0 0 c 5 1" >> /initram.txt \
    && echo "nod /dev/null 0666 0 0 c 1 3" >> /initram.txt

##################
# recompile with included initram
##################
RUN  /linux-*/scripts/config --file /linux-*/.config --set-str CONFIG_INITRAMFS_SOURCE '/initram.txt' \
    && make -C linux-* ARCH=um olddefconfig \
    && make -C linux-* ARCH=um -j$(nproc)

##################
# artefact
##################
RUN mkdir -p /uml \
    && cp linux-*/linux /uml/ \
    && mkdir -p /empty

##################
# PoC we do not need anything than a /tmp dir
##################
FROM scratch
COPY --from=build /empty /tmp
COPY --from=build /uml /uml
ENV TMPDIR=/tmp
ENTRYPOINT [ "/uml/linux" ]