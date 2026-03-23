FROM tomcat:9-jdk11

ENV IIQ_HOME=/opt/iiq

RUN apt-get update && apt-get install -y \
    unzip \
    mysql-client \
    netcat-openbsd \
    gettext \
    ant \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $IIQ_HOME

COPY iiq/ $IIQ_HOME/
COPY code/ $IIQ_HOME/code/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x $IIQ_HOME/code/build.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]