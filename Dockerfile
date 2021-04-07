FROM debian:buster

# depend
RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates wget git build-essential cmake libuv1-dev libssl-dev libhwloc-dev automake libtool autoconf
# copy
RUN mkdir -p /build/
WORKDIR /build
COPY ./ /build
# build
RUN cd scripts && ./build_deps.sh && mkdir ../build && cd ../build && cmake .. -DXMRIG_DEPS=scripts/deps && make -j$(nproc)



FROM debian:buster-slim

#ARG LINUX_MIRRORS=http://mirrors.aliyun.com
#ARG LINUX_MIRRORS=http://mirrors.163.com
# set version label
LABEL maintainer="suisrc@outlook.com"

# update linux
RUN if [ ! -z ${LINUX_MIRRORS+x} ]; then \
        mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
        echo "deb ${LINUX_MIRRORS}/debian/ buster main non-free contrib" >>/etc/apt/sources.list &&\
        echo "deb ${LINUX_MIRRORS}/debian-security buster/updates main" >>/etc/apt/sources.list &&\
        echo "deb ${LINUX_MIRRORS}/debian/ buster-updates main non-free contrib" >>/etc/apt/sources.list &&\
        echo "deb ${LINUX_MIRRORS}/debian/ buster-backports main non-free contrib" >>/etc/apt/sources.list &&\
        echo "deb-src ${LINUX_MIRRORS}/debian/ buster main non-free contrib" >>/etc/apt/sources.list &&\
        echo "deb-src ${LINUX_MIRRORS}/debian-security buster/updates main" >>/etc/apt/sources.list &&\
        echo "deb-src ${LINUX_MIRRORS}/debian/ buster-updates main non-free contrib" >>/etc/apt/sources.list &&\
        echo "deb-src ${LINUX_MIRRORS}/debian/ buster-backports main non-free contrib" >>/etc/apt/sources.list; \
    fi &&\
    apt-get update && apt-get install --no-install-recommends -y ca-certificates &&\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

RUN mkdir -p /www/
WORKDIR /www

EXPOSE 80
ENTRYPOINT ["./xmrig"]

#deploy files
COPY --from=0 build/xmrig /www/
ADD ["src/config.json", "/www/"]