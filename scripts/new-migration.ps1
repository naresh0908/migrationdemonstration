# Helper script to create a new migration file
# Usage: .\scripts\new-migration.ps1 -Description "add_user_roles"

param(
    [Parameter(Mandatory=$true)]
    [string]$Description
)

Write-Host "`n📝 Creating new migration file...`n" -ForegroundColor Cyan

# Get the next version number
$migrationsPath = "db\migrations"
$migrations = Get-ChildItem -Path $migrationsPath -Filter "V*.sql" | Sort-Object Name

if ($migrations.Count -eq 0) {
    $nextVersion = 1
} else {
    $lastMigration = $migrations[-1].Name
    if ($lastMigration -match "^V(\d+)__") {
        $nextVersion = [int]$matches[1] + 1
    } else {
        Write-Host "⚠️  Warning: Could not determine next version. Using V1." -ForegroundColor Yellow
        $nextVersion = 1
    }
}

# Clean description (replace spaces with underscores, remove special chars)
$cleanDescription = $Description -replace '\s+', '_' -replace '[^\w_]', ''

# Create filename
$filename = "V${nextVersion}__${cleanDescription}.sql"
$filepath = Join-Path $migrationsPath $filename

# Create file with template
$template = @"
-- Migration: $Description
-- Author: $env:USERNAME
-- Date: $(Get-Date -Format "yyyy-MM-dd")
-- Description: [Add detailed description here]

-- Write your migration SQL here
-- Example:
-- CREATE TABLE example (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(255) NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

"@

Set-Content -Path $filepath -Value $template

Write-Host "✅ Migration file created: $filename" -ForegroundColor Green
Write-Host "📂 Location: $filepath" -ForegroundColor Gray
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Edit the file and add your SQL commands"
Write-Host "  2. Test locally: .\scripts\migrate.ps1 -Command migrate"
Write-Host "  3. Commit and push when ready`n"

# Open file in default editor (optional)
$openFile = Read-Host "Open file in default editor? (y/n)"
if ($openFile -eq 'y' -or $openFile -eq 'Y') {
    Start-Process $filepath
}
