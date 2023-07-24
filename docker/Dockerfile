FROM mcr.microsoft.com/dotnet/aspnet:6.0
ARG JITBIT_APP_DIR="app"

# Ensure we listen on any URL
ENV DOTNET_URLS=http://+:5000

# COPY in app
COPY $JITBIT_APP_DIR /jitbit

WORKDIR /jitbit

# Expose default
EXPOSE 5000/tcp

# Execute process
ENTRYPOINT ["dotnet", "HelpDesk.dll"]
