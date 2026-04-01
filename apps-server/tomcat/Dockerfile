# apps-server/tomcat/Dockerfile
FROM tomcat:9-jdk11

# Optional override (safe if empty)
COPY conf/ /usr/local/tomcat/conf/
COPY webapps/ /usr/local/tomcat/webapps/
COPY alpha-conf/ /alpha-conf/
COPY init-alpha.sh /init-alpha.sh

RUN chmod +x /init-alpha.sh

CMD ["/init-alpha.sh"]
EXPOSE 8080