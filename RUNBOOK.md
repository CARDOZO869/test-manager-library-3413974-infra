# Arranque y verificación local

Prerequisitos: Docker Desktop con Compose, PowerShell y los seis repositorios como carpetas hermanas. Se necesitan los archivos locales existentes `infra/.env` y `api/.env`. No se deben copiar ejemplos sobre archivos existentes ni cambiar sus claves. Infra requiere DB_PASSWORD y LIBRARY_ADMIN_PASSWORD; API requiere APP_KEY válido. No publicar dichos archivos.

Desde esta carpeta:

```powershell
.\Start-Library.ps1
```

El script comprueba configuración, instala vendor si falta, construye/inicia servicios, aplica únicamente las dos migraciones library y ejecuta library:bootstrap-admin. No reemplaza .env ni rota claves del admin existente. Nunca usar migrate:fresh o down -v sobre esta instalación.

App: http://localhost:5173. Health: http://localhost:8000/api/v1/health. API base: /api/v1. `docker compose ps` permite comprobar salud. El sitio público es independiente: abrir el index.html del repositorio page, o ejecutar allí `node preview.mjs` para http://127.0.0.1:4178.

El volumen api_vendor usa archivos Linux para evitar coste del montaje Windows. Si cambia composer.lock, actualizar ese volumen explícitamente con `docker compose exec api composer install --no-interaction --prefer-dist`; reconstruir la imagen por sí solo no reemplaza dependencias de un volumen existente. No eliminar postgres_data ni otros volúmenes para renovar dependencias.

## Pruebas aisladas

La base manager_library_verification se creó durante la auditoría y se conserva. No apuntar pruebas de fixtures concurrentes/benchmark a manager_library. El servidor HTTP de pruebas con Clock fijo solo admite APP_ENV=testing y esa base exacta; no configurarlo en el servicio normal.

```powershell
docker compose exec -T -e DB_CONNECTION=pgsql -e DB_DATABASE=manager_library_verification api php artisan test
docker compose exec -T app npm test
docker compose exec -T app npm run lint
docker compose exec -T app npm run build
```

La prueba concurrente HTTP necesita un servidor adicional en 8001 con varios workers y DB aislada; sin él puede quedar omitida. Para repetir toda la evidencia abrir otra terminal y mantener:

```powershell
docker compose exec -T -e APP_ENV=testing -e DB_CONNECTION=pgsql -e DB_DATABASE=manager_library_verification -e LIBRARY_CLOCK_NOW=2026-10-26T12:00:00Z -e PHP_CLI_SERVER_WORKERS=4 api php artisan serve --host=0.0.0.0 --port=8001 --no-reload
```

Después ejecutar suite en la primera terminal. Al terminar interrumpir servidor temporal; si es necesario reiniciar solamente api. No usar el Clock fijo sobre datos habituales. Para fixture de rendimiento consultar tests/Support/benchmark-search.php: su guardia exige DB aislada. Las credenciales llegan desde entorno; no escribirlas en comandos, archivos compartidos o chat.

## Recuperación segura

Duplicados React respaldados en ../backups/react-duplicates-20261010. Log original cifrado en ../backups/security/laravel-original.dpapi, recuperable con DPAPI del mismo usuario Windows. Los backups están fuera de repositorios. Los datos de demostración/manuales permanecen para revisión.

Consulta ../test-manager-library-3413974-docs/implementation-laravel-react/FINAL-REPORT.md y COMPLIANCE-MATRIX.md para resultados y límites. Compose está destinado a desarrollo local; publicación requiere TLS y servidor PHP de producción.
