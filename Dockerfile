# Debian Docker Base Image with Useful Tools

FROM debian:jessie
MAINTAINER Patrick Baber <patrick.baber@servivum.com>

# Install utilities
RUN apt-get update && apt-get install -y \
	ca-certificates \
	cron \
	curl \
	git \
	nano \
	openssh-server \
	ssmtp \
	supervisor \
	unzip \
	vim \
	wget

# Configure Supervisor
# @TODO: Replace supervisord with S6: http://blog.tutum.co/2014/12/02/docker-and-s6-my-new-favorite-process-supervisor/
# @TODO: To inject an authorized_keys file, we have to use a startup script which copies the external mount to /root/.ssh/authorized_keys with the right permissions.
RUN mkdir -p /var/log/supervisor
COPY etc/supervisor/conf.d/00_supervisord.conf /etc/supervisor/conf.d/00_supervisord.conf

# Configure SSH
ENV NOTVISIBLE "in users profile"
COPY etc/supervisor/conf.d/sshd.conf /etc/supervisor/conf.d/sshd.conf
RUN mkdir -p /var/run/sshd && \
    mkdir /root/.ssh && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

# Configure cron
# @TODO: Configure cron
# https://github.com/mailtank-ru/rsstank/blob/master/docker/files/cron-supervisor.conf
# https://www.ekito.fr/people/run-a-cron-job-with-docker/

# Clean up
RUN apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22
CMD ["/usr/bin/supervisord"]