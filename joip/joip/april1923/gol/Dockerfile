FROM tomcat:9.0.73-jdk8-corretto-al2
ADD https://referenceapplicationskhaja.s3.us-west-2.amazonaws.com/gameoflife.war /tomcat/webapps/gameoflife.war
WORKDIR /tomcat/webapps
EXPOSE 8080
CMD [ "java", "-jar", "gameoflife.war" ]