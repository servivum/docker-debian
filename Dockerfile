# Debian Docker Base Image + Useful Tools

FROM debian:jessie
MAINTAINER Patrick Baber <patrick.baber@servivum.com>

# Install utilities
RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	git \
	nano \
	openssh-server \
	supervisor \
	unzip \
	vim \
	wget

# Configure Supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure SSH
# @TODO: Enable key auth only!
ENV NOTVISIBLE "in users profile"
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

# Clean up
RUN apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22
CMD ["/usr/bin/supervisord"]