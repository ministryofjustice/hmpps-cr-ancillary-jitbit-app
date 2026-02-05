FROM mcr.microsoft.com/dotnet/aspnet:10.0

RUN apt-get update && \
    apt-get install -y \
        wget \
        zlib1g-dev \
        libpam0g \
        libpam-modules \
        libpam-runtime \
        gnutls-bin \
        perl \
    && apt-get dist-upgrade -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

# set timezone
ENV TZ="Europe/London"
RUN rm /etc/localtime && \
  ln -s /usr/share/zoneinfo/$TZ /etc/localtime

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