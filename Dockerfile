FROM alpine

ARG RKE_VERSION=v1.2.1
ARG HELM_VERSION=v3.2.0

WORKDIR /tmp

RUN apk add --no-cache \
        ansible \
        openssh \
        openssl \
        curl \
        wget \
        openssl \
        busybox-extras \
        sshpass \
        bash \
        bash-completion \
        jq \
    &&  apk del --purge \
    &&  set -x \
    &&  ansible-galaxy install ahuffman.resolv \
    &&  mkdir -p /root/ansible \
    &&  rm -rf /var/cache/apk/* /tmp/* \
    &&  sed -i 's:bin/ash:bin/bash:g' /etc/passwd \
    &&  cat /etc/profile \
    &&  mkdir -p /root/.ssh/

RUN     curl -LsS https://storage.googleapis.com/kubernetes-release/release/v$( curl -LSs -s https://api.github.com/repos/kubernetes/kubernetes/git/refs/tags | jq -r .[].ref | awk -F/ '{print $3}' | grep v | awk -Fv '{print $2}' | grep -v [a-z] | awk -F"." '{arr[$1"."$2]=$3}END{for(var in arr){if(arr[var]==""){print var}else{print var"."arr[var]}}}'|sort -r  -u -t "." -k1n,1 -k2n,2 -k3n,3 | tail -1 )/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    &&  chmod +x /usr/local/bin/kubectl \
    &&  rm -rf /tmp

RUN     curl -LsS -o /tmp/helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    &&  cd /tmp \
    &&  tar -zxvf helm.tar.gz \
    &&  rm -rf helm.tar.gz \
    &&  mv linux-amd64/helm /usr/local/bin/helm \
    &&  chmod +x /usr/local/bin/helm \
    &&  rm -rf /tmp

# 配置自动补全
COPY    bashrc /root/.bashrc
COPY    ansible-completion.bash /etc/profile.d/ansible-completion.bash
COPY    config /root/.ssh/

RUN     cat /root/.bashrc >> /etc/profile \
    &&  mkdir -p /tmp

WORKDIR /etc/ansible
VOLUME ["/root/ansible"]

CMD [ "bash" ]
