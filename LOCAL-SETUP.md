# Manager Library — Docker local (P2)

## Prerequisites
Docker Desktop with Compose; Laravel source in the sibling `test-manager-library-3413974-api` directory, including `vendor/`, `artisan`, and a valid Laravel `.env` with `APP_KEY`.

## First run (PowerShell)
From `test-manager-library-3413974-infra`:

```powershell
Copy-Item .env.example .env
notepad .env
docker compose config
docker compose up -d --build
docker compose ps
docker compose logs api --tail=80
```

Replace the placeholder password in `infra/.env` with a private local value. The database password is passed to Laravel through Compose. Do not commit either local `.env`.

Ensure `bootstrap/app.php` in the local API repository registers `api: __DIR__.'/../routes/api.php'` and that `routes/api.php` defines GET `/v1/health`. Then check:

```powershell
Invoke-RestMethod http://localhost:8000/api/v1/health
```

Expected: `status: ok`. If `APP_KEY` is missing, generate it locally inside the API container with `docker compose exec api php artisan key:generate`; it is stored in the mounted API `.env`. If PHP dependencies are missing, install them locally before starting the container.

## Notes
- PostgreSQL 16 starts with an empty database; **Laravel migrations**, not the infra repository, will own schema `library` and its six tables in T-02.
- No host PostgreSQL port is published.
- The API runs on PHP 8.4 with pdo_pgsql and pgsql.
- Do not run `docker compose down -v` unless intentionally deleting the local database volume.
- The React service will be added in a later phase.
