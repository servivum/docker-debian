![Debian Jessie](https://img.shields.io/badge/Debian-Jessie-brightgreen.svg?style=flat-square) [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT) [![Travis](https://img.shields.io/travis/servivum/docker-debian.svg?style=flat-square)](https://travis-ci.org/servivum/docker-debian)

# Debian Docker Base Image with Useful Tools

Dockerfile for extending official Debian image with useful tools, e.g. Git, Wget, etc. The Image is a good starting 
point to create your own small images with some handy tools. See [Docker Hub](https://hub.docker.com/r/servivum/debian) 
for more details about the image.

## What's inside?

- ca-certificates: Brings root certs for trusting secured connections with common CAs. 
- cron: Use Cron jobs for scheduling tasks like cleanup processes.
- curl: Swiss army knife to use various number of protocols.
- git: THE version control system.
- nano: Easy editor for modifying files.
- openssh-server: For connecting to the container via SSH and executing commands within.
- rsync: Use it for copying files from server A to server B.
- ssmtp: Tiny mail server for sending mails from your application to the world. 
- supervisor: Helper for running multiple processes in a container, e.g. cron and openssh-server.
- unzip: Unpack ZIP archives.
- vim: Powerful editor for nerds.
- wget: The standard for downloading archives.

## Supported Tags

- `jessie`, `latest` [(Dockerfile)](https://github.com/servivum/docker-debian)

## Log into container via SSH with public key

Mount your public key into `/authorized_keys` within the container. Example:

```bash
docker run -d -P -v ~/.ssh/id_rsa.pub:/authorized_keys:ro servivum/debian
```

## Use sSMTP with external SMTP relay server

sSMTP is like a proxy which delegates the mails to a real MTA like 
postfix. With these environment variables it is possible to define a 
relay server with the corresponding credentials.

```bash
docker run -d -P \
-e "SMTP_HOST=smtp.example.com" \
-e "SMTP_AUTH_USER=test@example.com" \
-e "SMTP_AUTH_PASS=secret" \
-e "SMTP_STARTTLS=true" \
servivum/debian
```
