FROM        maven:alpine AS build
MAINTAINER  Daniel Maganto Martín <dmagantomartin@gmail.com>

WORKDIR /
RUN apk update && \
    apk add git
RUN git clone https://github.com/dmaganto-stratio/jmx_exporter.git
RUN cd /jmx_exporter && \
    mvn package
 
FROM alpine
RUN apk update && \
    apk add openjdk8-jre-base bash curl jq openssl
COPY --from=build /jmx_exporter/jmx_prometheus_httpserver/target/jmx_prometheus_httpserver-*-SNAPSHOT-jar-with-dependencies.jar /jmx_exporter.jar
COPY --from=build /jmx_exporter/example_configs/kafka-0-8-2.yml /
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ARG KMS_UTILS=0.2.1
ADD http://sodio.stratio.com/repository/paas/kms_utils/${KMS_UTILS}/kms_utils-${KMS_UTILS}.sh /kms_utils.sh

ENTRYPOINT [ "/entrypoint.sh" ]
