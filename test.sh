#!/bin/bash
set -ev

echo "Building and running image ..."
docker build -t debian .
docker run -d -P \
-e "SMTP_HOST=testhost" \
-e "SMTP_AUTH_USER=testuser" \
-e "SMTP_AUTH_PASS=testpassword" \
-e "SMTP_STARTTLS=teststarttls" \
--name debian debian

echo "Waiting some time, because the process manager inside the container runs async to the docker run command ..."
sleep 10

echo "Checking if container is running ..."
docker ps | grep debian

echo "Checking existence of some binaries and packages ..."
docker exec debian dpkg -s ca-certificates
docker exec debian which cron
docker exec debian which curl
docker exec debian which git
docker exec debian which nano
docker exec debian which sshd
docker exec debian which ssmtp
docker exec debian which supervisord
docker exec debian which unzip
docker exec debian which vim
docker exec debian which wget

echo "Check if environment variables are present in ssmtp config file ..."
docker exec debian grep testhost /etc/ssmtp/ssmtp.conf
docker exec debian grep testuser /etc/ssmtp/ssmtp.conf
docker exec debian grep testpassword /etc/ssmtp/ssmtp.conf
docker exec debian grep teststarttls /etc/ssmtp/ssmtp.conf

echo "Check if sshd is running inside the container ..."
docker exec debian ps aux | grep sshd

echo "Connecting to ssh and run test command ..."
ssh-keygen -f ~/.ssh/test_rsa -t rsa -N ''
docker cp ~/.ssh/test_rsa.pub debian:/root/.ssh/authorized_keys
docker exec -ti debian cat /root/.ssh/authorized_keys
docker exec -ti debian chown root:root /root/.ssh/authorized_keys

echo "Getting IP address of external docker-machine or using localhost instead ..."
if ! docker-machine ip; then
    export IP="127.0.0.1"
else
    export IP=$(docker-machine ip)
fi

export PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' debian)
docker ps
ssh -v -p $PORT -i ~/.ssh/test_rsa -o "StrictHostKeyChecking no" -t root@$IP "pwd"