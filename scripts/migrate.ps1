# Flyway Migration Helper Scripts for Windows
# Run this script to perform common Flyway operations

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('migrate', 'info', 'validate', 'clean', 'repair', 'baseline', 'help')]
    [string]$Command = 'help'
)

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# Check if Flyway is installed
function Test-FlywayInstalled {
    try {
        $null = flyway -v 2>&1
        return $true
    } catch {
        return $false
    }
}

# Display help
function Show-Help {
    Write-Info "`n========================================"
    Write-Info "  Flyway Migration Helper"
    Write-Info "========================================`n"
    
    Write-Host "Usage: .\scripts\migrate.ps1 -Command <command>`n"
    
    Write-Host "Available commands:"
    Write-Host "  migrate   - Run all pending migrations"
    Write-Host "  info      - Show migration status"
    Write-Host "  validate  - Validate applied migrations"
    Write-Host "  clean     - ⚠️  Drop all database objects (use with caution!)"
    Write-Host "  repair    - Repair schema history table"
    Write-Host "  baseline  - Baseline existing database"
    Write-Host "  help      - Show this help message`n"
    
    Write-Host "Examples:"
    Write-Host "  .\scripts\migrate.ps1 -Command migrate"
    Write-Host "  .\scripts\migrate.ps1 -Command info`n"
}

# Main script
Write-Info "`n🔄 Flyway Migration Tool`n"

# Check if Flyway is installed
if (-not (Test-FlywayInstalled)) {
    Write-Error "❌ Flyway is not installed or not in PATH`n"
    Write-Host "Please install Flyway first:"
    Write-Host "  - Using Chocolatey: choco install flyway.commandline"
    Write-Host "  - Manual: Download from https://flywaydb.org/download`n"
    exit 1
}

# Check if flyway.conf exists
if (-not (Test-Path "flyway.conf")) {
    Write-Error "❌ flyway.conf not found!"
    Write-Host "Please make sure you're running this from the project root.`n"
    exit 1
}

# Execute command
switch ($Command) {
    'migrate' {
        Write-Info "🚀 Running database migrations...`n"
        flyway migrate
        if ($LASTEXITCODE -eq 0) {
            Write-Success "`n✅ Migrations completed successfully!`n"
        } else {
            Write-Error "`n❌ Migration failed!`n"
            exit 1
        }
    }
    
    'info' {
        Write-Info "📊 Checking migration status...`n"
        flyway info
    }
    
    'validate' {
        Write-Info "🔍 Validating migrations...`n"
        flyway validate
        if ($LASTEXITCODE -eq 0) {
            Write-Success "`n✅ All migrations are valid!`n"
        } else {
            Write-Error "`n❌ Validation failed!`n"
            exit 1
        }
    }
    
    'clean' {
        Write-Warning "`n⚠️  WARNING: This will DELETE ALL database objects!`n"
        $confirmation = Read-Host "Are you sure you want to continue? (Type 'YES' to confirm)"
        if ($confirmation -eq 'YES') {
            Write-Info "🧹 Cleaning database...`n"
            flyway clean
            if ($LASTEXITCODE -eq 0) {
                Write-Success "`n✅ Database cleaned successfully!`n"
            }
        } else {
            Write-Info "❌ Operation cancelled.`n"
        }
    }
    
    'repair' {
        Write-Info "🔧 Repairing schema history...`n"
        flyway repair
        if ($LASTEXITCODE -eq 0) {
            Write-Success "`n✅ Schema history repaired!`n"
        }
    }
    
    'baseline' {
        Write-Info "📍 Baselining database...`n"
        $version = Read-Host "Enter baseline version (default: 1)"
        if ([string]::IsNullOrEmpty($version)) { $version = "1" }
        
        flyway baseline -baselineVersion=$version
        if ($LASTEXITCODE -eq 0) {
            Write-Success "`n✅ Database baselined at version $version!`n"
        }
    }
    
    'help' {
        Show-Help
    }
}

Write-Host ""
