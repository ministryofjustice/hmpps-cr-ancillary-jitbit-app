FROM mcr.microsoft.com/dotnet/aspnet:8.0

RUN apt-get update && \
  apt-get install -y wget && \
  apt-get dist-upgrade -y && \
  apt-get autoremove -y && \
  apt-get clean && \
  update-ca-certificates


COPY ./debian-testing.sources /etc/apt/sources.list.d/debian-testing.sources
COPY ./default-release /etc/apt/apt.conf.d/default-release
COPY ./testing.pref /etc/apt/preferences.d/testing.pref

RUN apt update && apt install -t testing zlib1g-dev -y

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
