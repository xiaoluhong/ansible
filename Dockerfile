FROM alpine

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN echo "https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable//main/" > /etc/apk/repositories; \
    echo "https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community/" >> /etc/apk/repositories; \
    echo "https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/releases/"  >> /etc/apk/repositories; \
    apk add --no-cache ansible openssh curl wget openssl busybox-extras python bash bash-completion \
&& set -x \
&& apk add --update $RUNTIME_DEPS \
&& apk add --virtual build_deps $BUILD_DEPS \
&& cp /usr/bin/envsubst /usr/local/bin/envsubst \
&& apk del build_deps \
&& mkdir -p /root/ansible \
&& rm -rf /var/cache/apk/* /tmp/* 

COPY bashrc /root/.bashrc
ADD https://www.cnrancher.com/download/rke/rke_linux-amd64 /usr/bin/rke
ADD https://www.cnrancher.com/download/kubectl/kubectl_amd64-linux /usr/bin/kubectl
RUN curl -LS -O https://storage.googleapis.com/kubernetes-helm/helm-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | \
    grep tag_name | cut -d '"' -f 4)-linux-amd64.tar.gz \
    && tar -zxf helm-*.tar.gz \
    && cd helm* && cp helm/usr/local/bin

RUN chmod +x /usr/local/bin/helm ; \
    chmod +x /usr/local/bin/kubectl ; \
    chmod +x /usr/local/bin/rke ; \
    sed -i 's:bin/ash:bin/bash:g' /etc/passwd 

WORKDIR /etc/ansible
VOLUME ["/root/ansible"]

CMD [ "bash" ]