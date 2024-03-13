FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine-amd64

RUN apk update && \
  apk upgrade && \
  apk add ca-certificates && \
  update-ca-certificates && \
  rm -rf /var/cache/apk/*

# Fix CVE-2023-2650, CVE-2023-1255
RUN apk upgrade libssl3 libcrypto3

RUN apk add tzdata
# set timezone
ENV TZ="Europe/London"
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# see https://github.com/dotnet/dotnet-docker/blob/main/samples/enable-globalization.md
ENV \
  DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8

RUN apk add --no-cache \
  icu-data-full \
  icu-libs

# Set jitbit app directory
ARG JITBIT_APP_DIR="app"

# Ensure we listen on any URL
ENV DOTNET_URLS=http://+:5000

# COPY in app
COPY ./app /jitbit

# Set user
RUN adduser --disabled-password appuser -u 1001 && \
  chown -R appuser:appuser /jitbit

# Expose default
EXPOSE 5000/tcp

# Execute process
USER 1001
WORKDIR /jitbit
ENTRYPOINT ["dotnet", "HelpDesk.dll"]
