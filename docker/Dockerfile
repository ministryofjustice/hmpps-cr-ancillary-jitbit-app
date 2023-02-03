FROM alpine:3.17


RUN apk add aspnetcore6-runtime

# Set jitbit app version - this is used to download the correct version of the app files from s3
ENV JITBIT_APP_VERSION=10_8 

# Ensure we listen on any URL
ENV DOTNET_URLS=http://+:5000

# COPY in app
COPY app/HelpDesk_${JITBIT_APP_VERSION} /jitbit

# Set user
RUN adduser --disabled-password appuser -u 1001 && \
  chown -R appuser:appuser /jitbit

# Expose default
EXPOSE 5000/tcp

# Execute process
USER 1001
WORKDIR /jitbit
ENTRYPOINT ["dotnet", "HelpDesk.dll"]
