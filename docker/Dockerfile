FROM alpine:3.15

# Add .NET dependencies, based on https://learn.microsoft.com/en-us/dotnet/core/install/linux-alpine
RUN apk add bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib
# Add dependencies needed by installer

# Install dotnetcore runtime
# Based on https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script

# Install wget - the script uses this
RUN apk add wget

COPY dotnet-install.sh /tmp/dotnet-install.sh
RUN chmod +x /tmp/dotnet-install.sh
RUN /tmp/dotnet-install.sh -c 6.0 --runtime aspnetcore --install-dir /dotnet

# Add dotnetcore cli to PATH
ENV DOTNET_ROOT=/dotnet
ENV PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

# Ensure we listen on any URL
ENV DOTNET_URLS=http://+:5000

# COPY in app
COPY app/HelpDesk /jitbit

# Set user
RUN adduser --disabled-password appuser -u 1001 && \
  chown -R appuser:appuser /dotnet && \
  chown -R appuser:appuser /jitbit

# Expose default
EXPOSE 5000/tcp

# Execute process
USER 1001
WORKDIR /jitbit
ENTRYPOINT ["/dotnet/dotnet", "HelpDesk.dll"]

