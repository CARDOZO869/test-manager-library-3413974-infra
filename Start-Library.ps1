$ErrorActionPreference = 'Stop'
$infraPath = $PSScriptRoot
$workspacePath = Split-Path $infraPath -Parent
$apiPath = Join-Path $workspacePath 'test-manager-library-3413974-api'
$composePath = Join-Path $infraPath 'docker-compose.yml'
foreach ($envPath in @((Join-Path $infraPath '.env'), (Join-Path $apiPath '.env'))) {
    if (!(Test-Path -LiteralPath $envPath)) { throw "Configura primero el archivo local $envPath. Este script no crea ni reemplaza credenciales." }
}
if (!(Test-Path -LiteralPath (Join-Path $apiPath 'vendor/autoload.php'))) {
    docker run --rm --mount "type=bind,source=$apiPath,target=/app" --workdir /app composer:2 install --no-interaction --prefer-dist --no-scripts --ignore-platform-req=ext-pdo_pgsql
    if ($LASTEXITCODE -ne 0) { throw 'No se pudieron instalar las dependencias PHP.' }
}
docker compose -f $composePath config --quiet
if ($LASTEXITCODE -ne 0) { throw 'La configuración Compose no es válida.' }
docker compose -f $composePath up -d --build
if ($LASTEXITCODE -ne 0) { throw 'No se pudieron iniciar los servicios.' }
docker compose -f $composePath exec -T api php artisan migrate --path=database/migrations/2026_10_10_120000_create_library_schema.php --path=database/migrations/2026_10_10_190508_add_domain_check_constraints_to_library_tables.php --force
if ($LASTEXITCODE -ne 0) { throw 'Falló la migración. No se borraron datos.' }
docker compose -f $composePath exec -T api php artisan library:bootstrap-admin
if ($LASTEXITCODE -ne 0) { throw 'Revisa la configuración del administrador existente.' }
Write-Output 'Aplicación: http://localhost:5173 · API: http://localhost:8000/api/v1/health'
