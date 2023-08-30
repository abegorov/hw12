FROM maven:3-eclipse-temurin-8 AS builder
ARG DB_HOST
ARG DB_NAME
ARG DB_USER
WORKDIR /build
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked <<EOT /bin/bash
    set -ex
    apt update
    apt install --yes git
    git clone https://github.com/shephertz/App42PaaS-Java-MySQL-Sample.git .
EOT
COPY --link <<EOT WebContent/Config.properties
app42.paas.db.ip = ${DB_HOST}
app42.paas.db.port = 3306
app42.paas.db.name = ${DB_NAME}
app42.paas.db.username = ${DB_USER}
EOT
RUN --mount=type=secret,id=db_password,required=true \
    echo "app42.paas.db.password = $(cat /run/secrets/db_password)" \
        >> WebContent/Config.properties
RUN <<EOT /bin/bash
    set -ex
    mvn clean
    mvn package
    mv target/*.war app42.war
EOT

FROM tomcat:9-jre8-temurin
WORKDIR /usr/local/tomcat/webapps
COPY --from=builder --link /build/app42.war /usr/local/tomcat/webapps/ROOT.war
