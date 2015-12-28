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

# Configure SSH
ENV NOTVISIBLE "in users profile"
RUN mkdir -p /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

# Clean up
RUN apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]