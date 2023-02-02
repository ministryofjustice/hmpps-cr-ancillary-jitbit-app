FROM alpine:3.17

RUN apk add aspnetcore6-runtime

# Ensure we listen on any URL
ENV DOTNET_URLS=http://+:5000

# COPY in app
COPY app/HelpDesk /jitbit

# Set user
RUN adduser --disabled-password appuser -u 1001 && \
  chown -R appuser:appuser /jitbit

# Expose default
EXPOSE 5000/tcp

# Execute process
USER 1001
WORKDIR /jitbit
ENTRYPOINT ["dotnet", "HelpDesk.dll"]
