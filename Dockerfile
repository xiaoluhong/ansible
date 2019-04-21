FROM alpine

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

WORKDIR /tmp

RUN echo "https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable//main/" > /etc/apk/repositories; \
    echo "https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community/" >> /etc/apk/repositories; \
    apk add --no-cache \
        ansible \
        openssh \
        curl \
        wget \
        openssl \
        busybox-extras \
        python \
        bash \
        bash-completion \
    && set -x \
    && apk add --update $RUNTIME_DEPS \
    && apk add --virtual build_deps $BUILD_DEPS \
    && cp /usr/bin/envsubst /usr/local/bin/envsubst \
    && apk del build_deps \
    && mkdir -p /root/ansible \
    && rm -rf /var/cache/apk/* /tmp/* 

COPY bashrc /root/.bashrc
RUN curl -LsS https://github.com/rancher/rke/releases/download/$(curl -s https://api.github.com/repos/rancher/rke/releases/latest | grep tag_name | cut -d '"' -f 4)/rke_linux-amd64 -o /usr/local/bin/rke
RUN curl -LsS https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
RUN curl -LsS -O https://storage.googleapis.com/kubernetes-helm/helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f 4)-linux-amd64.tar.gz \
    && tar -zxf helm-*.tar.gz \
    && rm -rf helm-*.tar.gz \
    && cd linux-amd64  \
    && cp helm /usr/local/bin

RUN    chmod +x /usr/local/bin/helm \
    && chmod +x /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/rke \
    && sed -i 's:bin/ash:bin/bash:g' /etc/passwd 

WORKDIR /etc/ansible
VOLUME ["/root/ansible"]

CMD [ "bash" ]