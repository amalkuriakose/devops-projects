FROM docker:dind

RUN apk add git nodejs npm openjdk17-jdk curl wget ca-certificates aws-cli

RUN wget https://github.com/aquasecurity/trivy/releases/download/v0.55.0/trivy_0.55.0_Linux-64bit.tar.gz

RUN tar -xvzf trivy_0.55.0_Linux-64bit.tar.gz

RUN mv trivy /usr/local/bin/