FROM ubuntu
RUN apt-get -q update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install apt-utils tzdata
RUN apt-get -qy install git openssh-client openssh-server; \
    cd /etc/ssh; mv ssh_config ssh_config.old; mv sshd_config sshd_config.old
ADD ssh_config sshd_config /etc/ssh/
ADD id_ed25519 id_ed25519.pub authorized_keys /root/.ssh/
RUN chmod 700 ~root/.ssh/
ADD ./entryPoint.sh /root
RUN chmod +x /root/entryPoint.sh
ARG ID
ENV ID=${ID}
ARG IP
ENV IP=${IP}
CMD ["bash","-c","/root/entryPoint.sh $ID $IP"]
