# .NET SDK is needed to restore and publish the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY WatchlistService.csproj ./
RUN dotnet restore WatchlistService.csproj
COPY . .
RUN dotnet publish WatchlistService.csproj -c Release -o /app/publish --no-restore /p:UseAppHost=false

# ASP.NET runtime is much smaller than the full SDK
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "WatchlistService.dll"]
