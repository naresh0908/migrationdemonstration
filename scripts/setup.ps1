# Quick setup script for new team members
# This script helps initialize the database for first-time setup

Write-Host "`n=======================================" -ForegroundColor Cyan
Write-Host "  Database Setup Wizard" -ForegroundColor Cyan
Write-Host "=======================================`n" -ForegroundColor Cyan

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check if PostgreSQL is installed
try {
    $pgVersion = psql --version
    Write-Host "✅ PostgreSQL found: $pgVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgreSQL not found. Please install PostgreSQL first." -ForegroundColor Red
    exit 1
}

# Check if Flyway is installed
try {
    $flywayVersion = flyway -v 2>&1 | Select-String "Flyway"
    Write-Host "✅ Flyway found: $flywayVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Flyway not found. Please install Flyway first." -ForegroundColor Red
    Write-Host "   Install with: choco install flyway.commandline" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n"

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file from template..." -ForegroundColor Yellow
    
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ .env file created. Please edit it with your database credentials.`n" -ForegroundColor Green
        
        # Prompt for database details
        Write-Host "Let's configure the database connection:`n" -ForegroundColor Cyan
        
        $dbHost = Read-Host "Database host (default: localhost)"
        if ([string]::IsNullOrEmpty($dbHost)) { $dbHost = "localhost" }
        
        $dbPort = Read-Host "Database port (default: 5432)"
        if ([string]::IsNullOrEmpty($dbPort)) { $dbPort = "5432" }
        
        $dbName = Read-Host "Database name"
        $dbUser = Read-Host "Database user"
        $dbPassword = Read-Host "Database password" -AsSecureString
        $dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))
        
        # Update .env file
        (Get-Content ".env") | ForEach-Object {
            $_ -replace "DB_HOST=.*", "DB_HOST=$dbHost" `
               -replace "DB_PORT=.*", "DB_PORT=$dbPort" `
               -replace "DB_NAME=.*", "DB_NAME=$dbName" `
               -replace "DB_USER=.*", "DB_USER=$dbUser" `
               -replace "DB_PASSWORD=.*", "DB_PASSWORD=$dbPasswordPlain"
        } | Set-Content ".env"
        
        # Update flyway.conf
        $jdbcUrl = "jdbc:postgresql://${dbHost}:${dbPort}/${dbName}"
        (Get-Content "flyway.conf") | ForEach-Object {
            $_ -replace "flyway.url=.*", "flyway.url=$jdbcUrl" `
               -replace "flyway.user=.*", "flyway.user=$dbUser" `
               -replace "flyway.password=.*", "flyway.password=$dbPasswordPlain"
        } | Set-Content "flyway.conf"
        
        Write-Host "`n✅ Configuration updated!`n" -ForegroundColor Green
    }
}

# Ask about seed data
Write-Host "Do you want to load seed data (sample data for development)?" -ForegroundColor Yellow
$loadSeeds = Read-Host "Load seeds? (y/n)"

if ($loadSeeds -eq 'y' -or $loadSeeds -eq 'Y') {
    Write-Host "`n📝 Updating Flyway config to include seed data..." -ForegroundColor Yellow
    
    # Update flyway.conf to include seeds
    $content = Get-Content "flyway.conf" -Raw
    if ($content -notmatch "filesystem:./db/seeds") {
        $content = $content -replace "flyway.locations=filesystem:./db/migrations", 
                                     "flyway.locations=filesystem:./db/migrations,filesystem:./db/seeds"
        Set-Content "flyway.conf" $content
    }
    Write-Host "✅ Seed data will be loaded`n" -ForegroundColor Green
}

# Run migrations
Write-Host "`n🚀 Running database migrations...`n" -ForegroundColor Cyan
flyway migrate

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Setup complete! Your database is ready.`n" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Check migration status: .\scripts\migrate.ps1 -Command info"
    Write-Host "  2. Start developing!`n"
} else {
    Write-Host "`n❌ Migration failed. Please check the error above.`n" -ForegroundColor Red
    exit 1
}
