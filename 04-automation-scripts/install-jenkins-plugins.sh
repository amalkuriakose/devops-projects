#!/bin/bash

set -x

if [[ -f "jenkins-cli.jar" ]]; then
    echo "Installing plugins..."
    java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_TOKEN install-plugin $@ -restart
else
    echo "jenkins-cli.jar does not exist."
    echo "Downloading jenkins-cli..."
    wget localhost:8080/jnlpJars/jenkins-cli.jar
    echo "Installing plugins..."
    java -jar jenkins-cli.jar -s http://localhost:8080/ -auth $JENKINS_USER:$JENKINS_TOKEN install-plugin $@ -restart
fi