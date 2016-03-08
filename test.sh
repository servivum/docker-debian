#!/bin/bash
set -ev

docker ps | grep debian
docker exec debian dpkg -s ca-certificates
docker exec debian which cron
docker exec debian which curl
docker exec debian which git
docker exec debian which nano
docker exec debian which sshd

# Check if sshd is running
docker exec debian ps aux | grep sshd

# Check if connecting to sshd is possible
ssh-keygen -f ~/.ssh/test_rsa -t rsa -N ''
docker cp ~/.ssh/test_rsa.pub debian:/root/.ssh/authorized_keys
docker exec -ti debian cat /root/.ssh/authorized_keys
docker exec -ti debian chown root:root /root/.ssh/authorized_keys
export IP=$(docker-machine ip)
export PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' debian)
docker ps
ssh -v -p $PORT -i ~/.ssh/test_rsa -o "StrictHostKeyChecking no" -t root@$IP "pwd"

docker exec debian which ssmtp
docker exec debian which supervisord
docker exec debian which unzip
docker exec debian which vim
docker exec debian which wget