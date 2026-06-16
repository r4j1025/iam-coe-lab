FROM tomcat:9-jdk11

# Optional: override tomcat config if present
# (safe even if folder is empty)
COPY tomcat/conf /usr/local/tomcat/conf/
COPY tomcat/webapps/ /usr/local/tomcat/webapps/

EXPOSE 8080