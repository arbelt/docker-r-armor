ARG HIVEMIND_VERSION=v1.0.6
ARG ARMOR_VERSION=0.4.13-alpha.cas.1
ARG GOMPLATE_VERSION=v3.3.1

FROM busybox AS build
ARG HIVEMIND_VERSION
ARG ARMOR_VERSION
ARG GOMPLATE_VERSION
ADD https://github.com/DarthSim/hivemind/releases/download/${HIVEMIND_VERSION}/hivemind-${HIVEMIND_VERSION}-linux-amd64.gz /hivemind.gz
ADD https://github.com/arbelt/armor/releases/download/v${ARMOR_VERSION}/armor_${ARMOR_VERSION}_linux_64-bit.tgz /armor.tgz
ADD https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim /gomplate
RUN gunzip /hivemind.gz
RUN tar -xvzf armor.tgz armor
RUN chmod 755 /hivemind
RUN chmod 755 /gomplate
RUN mkdir -p /out/usr/local/bin && mv /hivemind /out/usr/local/bin/ \
    && cp /gomplate /out/usr/local/bin/ \
    && cp /armor /out/usr/local/bin/

FROM rocker/shiny-verse
MAINTAINER Albert Wang <albert.zhao.wang@gmail.com>
RUN install2.r -- logger
COPY --from=build /out /
COPY /runApp.r /usr/local/bin/
COPY /Procfile /
COPY /armor.yml /etc/armor/config.yml
RUN echo 'options(shiny.port = 3838)' >> /usr/local/lib/R/etc/Rprofile.site
RUN useradd -m myuser
CMD ["hivemind"]
