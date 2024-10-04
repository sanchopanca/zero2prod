# Enable exception handling
$ErrorActionPreference = "Stop"

# Check if a custom user has been set, otherwise default to 'postgres'
$DB_USER = if ($env:POSTGRES_USER) { $env:POSTGRES_USER } else { "postgres" }

# Check if a custom password has been set, otherwise default to 'password'
$DB_PASSWORD = if ($env:POSTGRES_PASSWORD) { $env:POSTGRES_PASSWORD } else { "password" }

# Check if a custom database name has been set, otherwise default to 'newsletter'
$DB_NAME = if ($env:POSTGRES_DB) { $env:POSTGRES_DB } else { "newsletter" }

# Check if a custom port has been set, otherwise default to '5432'
$DB_PORT = if ($env:POSTGRES_PORT) { $env:POSTGRES_PORT } else { "5432" }

# Launch postgres using Docker
docker run `
-e POSTGRES_USER=$DB_USER `
-e POSTGRES_PASSWORD=$DB_PASSWORD `
-e POSTGRES_DB=$DB_NAME `
-p "${DB_PORT}:5432" `
-d postgres `
postgres -N 1000
# ^ Increased maximum number of connections for testing purposes

# Keep pinging Postgres until it's ready to accept commands
$env:PGPASSWORD = $DB_PASSWORD
$connectionSuccessful = $false
while (-not $connectionSuccessful) {
    try {
        # Attempt to connect to the PostgreSQL server
        psql -h "localhost" -U $DB_USER -p $DB_PORT -d "postgres" -c '\q' -w 2>&1 | Out-Null
        $connectionSuccessful = $true
        Write-Host "Postgres is up and running on port $DB_PORT!"
    }
    catch {
        Write-Host "Postgres is still unavailable - sleeping"
        Start-Sleep -Seconds 1
    }
}


# Export DATABASE_URL environment variable
$env:DATABASE_URL = "postgres://${DB_USER}:$DB_PASSWORD@localhost:$DB_PORT/$DB_NAME"

# Execute SQLx database creation
sqlx database create

# Execute SQLx migrations
sqlx migrate run

Write-Host "Postgres has been migrated, ready to go!"
