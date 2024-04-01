FROM ubuntu:22.04
LABEL author="srikanth" org="qt" project="Jenkins"
RUN apt update && apt install curl -y
RUN apt install openjdk-17-jdk -y
RUN curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null && \
  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
RUN apt update && apt install jenkins -y 
USER jenkins
ENV JENKINS_HOME=/var/lib/jenkins
EXPOSE 8080
CMD [ "/usr/bin/jenkins" ]