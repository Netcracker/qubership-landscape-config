FROM maven:3.9.9-amazoncorretto-11-al2023 AS builder

ENV BUILD_DIR=/tmp/build

# Install unzip in Alpine
RUN yum install -y unzip

# Compile landscape-config-processor app
RUN mkdir -p $BUILD_DIR/qubership-landscape-config-processor
RUN mkdir -p $BUILD_DIR/built-config
RUN mkdir -p $BUILD_DIR/built-config/new-logos

WORKDIR $BUILD_DIR
# Clone repository with configuration-merge-processor application
RUN curl -JL -o qlcp.zip --url https://github.com/Netcracker/qubership-landscape-config-processor/archive/refs/heads/main.zip
RUN unzip qlcp.zip

# todo: remove this redundant step
# RUN curl -JL -o qlc.zip --url https://github.com/Netcracker/qubership-landscape-config/archive/refs/heads/main.zip
# RUN unzip qlc.zip

# Clone repository with original landscape configuration and SVG logos (we need them only todo: optimize this long step)
RUN curl -JL -o cncf.zip https://github.com/cncf/landscape/archive/refs/heads/master.zip
RUN unzip cncf.zip

# Compile & build processor app
WORKDIR $BUILD_DIR/qubership-landscape-config-processor-main
RUN ls -la
RUN /usr/bin/mvn clean package assembly:single
RUN cp ./target/landscape-config-processor-*.jar $BUILD_DIR/built-config/processor.jar

# Merge configurations
RUN mv $BUILD_DIR/landscape-master/hosted_logos $BUILD_DIR/built-config/logos
COPY landscape.yml $BUILD_DIR/built-config/landscape.yml
COPY added-items $BUILD_DIR/built-config/added-items
COPY added-logos $BUILD_DIR/built-config/logos

WORKDIR $BUILD_DIR/built-config
RUN echo "base-configuration-file-name=$BUILD_DIR/built-config/landscape.yml" >> ./processor.properties
RUN echo "extra-configurations-directory-name=$BUILD_DIR/built-config/added-items" >> ./processor.properties
RUN echo "result-configuration-file-name=$BUILD_DIR/built-config/result.yml" >> ./processor.properties
RUN echo "source-logos-folder=$BUILD_DIR/built-config/logos" >> ./processor.properties
RUN echo "dest-logos-folder=$BUILD_DIR/built-config/new-logos" >> ./processor.properties

RUN java -jar processor.jar ./processor.properties

# build landscape application
FROM public.ecr.aws/g6m3a0y9/landscape2:latest AS prod
ENV BUILD_DIR=/tmp/build
EXPOSE 80

USER landscape2
WORKDIR /home/landscape2

RUN landscape2 new --output-dir my-landscape
COPY --chown=landscape2 landscape2-config/settings.yml /home/landscape2/my-landscape/settings.yml
COPY --chown=landscape2 --from=builder $BUILD_DIR/built-config/result.yml /home/landscape2/my-landscape/data.yml
COPY --chown=landscape2 --from=builder $BUILD_DIR/built-config/logos /home/landscape2/my-landscape/logos
COPY --chown=landscape2 --from=builder $BUILD_DIR/built-config/new-logos /home/landscape2/my-landscape/logos

WORKDIR /home/landscape2/my-landscape
RUN landscape2 build --data-file data.yml --settings-file settings.yml --guide-file guide.yml --logos-path logos --output-dir build

## todo make new clear stage (only build directory is needed)

WORKDIR /home/landscape2/my-landscape
ENTRYPOINT ["landscape2", "serve", "--addr", "0.0.0.0:80", "--landscape-dir", "build"]
