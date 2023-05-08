FROM maven:3.9.1 as builder

COPY . /builds

WORKDIR /builds

RUN mvn clean package -Dmaven.test.skip=true

RUN ls -al /builds

FROM openjdk:8u151-jdk

ARG USER=app
ARG GROUP=app

ARG APPLICATION
ARG CLUSTER
ARG ENVIRONMENT

RUN groupadd --gid 10001 $GROUP && useradd --home-dir /home/$USER \
        --create-home --uid 10001 --gid 10001 --shell /bin/bash $USER

RUN echo "APPLICATION: $APPLICATION, CLUSTER: $CLUSTER, ENVIRONMENT: $ENVIRONMENT"

COPY --from=builder --chown=$USER:$GROUP /builds/target/*.jar /lib/app.jar

RUN mkdir -p /artifacts && tar -zcf /artifacts/artifacts.tar.gz /lib/app.jar

RUN chown -R $USER:$GROUP /artifacts

USER 10001