# Netflix — Docker task completion guide

This folder extends the original PSUT Netflix learning project. Keep the original `README.md`; this file documents the Docker work.

## Requirements
Docker Engine/Desktop with Docker Compose v2 and enough RAM/disk space for 16 containers. All commands are run inside the `netflix/` directory in Ubuntu WSL.

## Start
```bash
cp .env.example .env   # once; don't overwrite your existing .env
docker compose config --quiet
docker compose up -d --build
docker compose ps
```

## URLs
- http://localhost:8080 — React Netflix shell; login `admin` / `admin123`
- http://localhost:8080/studio — Next.js admin studio
- http://localhost:8080/gateway/health — gateway check
- http://localhost:8080/api/catalog/movies — catalog
- http://localhost:15672 — RabbitMQ console (`netflix` / `netflix`)
- http://localhost:9001 — MinIO console (`minioadmin` / `minioadmin`)

## Architecture
- API services: Spring Boot Auth + PostgreSQL; NestJS Catalog + MongoDB; Django Media + PostgreSQL + object storage; ASP.NET Core Watchlist + PostgreSQL.
- `media-worker` uses the same image as `media-service`, but runs `manage.py consume_events` instead of Gunicorn.
- Frontend: Shell, Auth MFE, Browse MFE (React/Vite + Nginx), Studio (Next.js standalone).
- Gateway: Nginx routing by URL path to all components.
- RabbitMQ carries events (`user.registered`, `media.uploaded`, `movie.deleted`).
- `frontend` connects the gateway to web apps and APIs; `backend` connects APIs to DBs and RabbitMQ; `storage` lets gateway and media reach MinIO. Gateway is intentionally absent from the `backend` network.
- Every persistent database and broker/storage service uses its own named volume.

## Verify
```bash
docker compose config --quiet
docker compose ps
curl -i http://localhost:8080/gateway/health
curl -i http://localhost:8080/api/catalog/movies
docker compose exec -T auth-service curl -fsS http://127.0.0.1:8081/health
docker compose exec -T media-service python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8000/health').read().decode())"
docker compose exec -T watchlist-service curl -fsS http://127.0.0.1:8080/health
docker compose logs --tail=60 auth-service media-service media-worker watchlist-service gateway
```
Note: `GET /health` is exposed internally by the services, whereas the gateway only routes paths starting with `/api/...`. This is why the last three checks run *inside* the relevant containers.

End-to-end: login; see seeded titles; go to Studio, upload poster/backdrop/MP4, and check whether catalog updates; add to My List; sign up a user; check RabbitMQ exchanges. Verify media objects in MinIO.

## Useful commands
```bash
docker compose logs -f media-service media-worker catalog-service
docker compose up -d --build auth-service
docker compose down
docker volume ls
git status --short
```
DO NOT use `docker compose down -v` unless you intentionally want to delete all database and upload data.

## Troubleshooting
- `service is unhealthy`: inspect `docker compose logs --tail=100 SERVICE` and `docker inspect CONTAINER`.
- Port already in use: `ss -ltnp` and stop the conflicting program; don't publish DB ports.
- If a front-end image fails to build: check npm-lockfile and `docker compose build --no-cache SERVICE`.
- If a service cannot connect to a DB: use Compose service DNS names, never localhost, for cross-container connections.
- If media cannot find MinIO: check `docker compose ps minio`, `docker compose logs minio`, and the storage network.
- The sample .env passwords are only for local practice; do not expose the demo publicly.

## Submission
Commit your Dockerfiles, `.dockerignore`s, `docker-compose.yml`, the existing nginx routing file, this guide, and screenshots showing Docker status plus Netflix/Studio. Never commit `.env`. Push to **your own** GitHub fork/repository. Kubernetes is not required in this Docker phase.

## Known limits
Build and runtime were not tested in the author's environment; validate on the actual user's Docker host. This is a learning setup, not a production deployment.
