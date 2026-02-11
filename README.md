# Database Migrations with Flyway

This project uses [Flyway](https://flywaydb.org/) for database version control and migrations to keep all team members' PostgreSQL databases in sync.

## 📋 Prerequisites

- PostgreSQL 12+ installed and running
- Java 8+ (required by Flyway)
- Flyway CLI installed

### Installing Flyway

#### Windows (using Chocolatey)
```powershell
choco install flyway.commandline
```

#### Windows (manual)
1. Download from https://flywaydb.org/download
2. Extract to a folder (e.g., `C:\flyway`)
3. Add to PATH: `C:\flyway`

#### macOS (using Homebrew)
```bash
brew install flyway
```

#### Linux
```bash
wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/9.22.3/flyway-commandline-9.22.3-linux-x64.tar.gz | tar xvz && sudo ln -s `pwd`/flyway-9.22.3/flyway /usr/local/bin
```

## 🚀 Quick Start

### 1. Initial Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd OMAmigrations
   ```

2. **Create your PostgreSQL database**
   ```sql
   CREATE DATABASE your_database_name;
   ```

3. **Configure database connection**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit .env with your database credentials
   ```
   
   Or directly edit `flyway.conf`:
   - Update `flyway.url` with your database name
   - Update `flyway.user` with your PostgreSQL username
   - Update `flyway.password` with your PostgreSQL password

### 2. Run Migrations

```bash
# Run all pending migrations
flyway migrate

# Check migration status
flyway info

# Validate applied migrations
flyway validate
```

### 3. Load Seed Data (Optional - for development)

```bash
# Update flyway.conf to include seeds location
flyway.locations=filesystem:./db/migrations,filesystem:./db/seeds

# Then run migrate
flyway migrate
```

## 📁 Project Structure

```
OMAmigrations/
├── db/
│   ├── migrations/          # Version-controlled schema changes
│   │   ├── V1__create_users_table.sql
│   │   ├── V2__create_products_table.sql
│   │   └── V3__create_orders_tables.sql
│   └── seeds/              # Sample data for development
│       ├── V100__seed_users.sql
│       ├── V101__seed_products.sql
│       └── V102__seed_orders.sql
├── flyway.conf             # Flyway configuration
├── .env.example            # Environment variables template
└── README.md               # This file
```

## 📝 Migration Naming Convention

Flyway uses a specific naming convention for migration files:

```
V{version}__{description}.sql
```

- **V**: Prefix for versioned migrations
- **version**: Numeric version (e.g., 1, 2, 3, 1.1, 2.1)
- **__**: Two underscores separator
- **description**: Snake_case description

### Examples:
- ✅ `V1__create_users_table.sql`
- ✅ `V2__create_products_table.sql`
- ✅ `V2.1__add_email_index.sql`
- ❌ `V1_create_users.sql` (single underscore)
- ❌ `v1__create_users.sql` (lowercase v)

### Seed Files:
Use version numbers >= 100 to distinguish from schema migrations:
- `V100__seed_users.sql`
- `V101__seed_products.sql`

## 🔄 Common Workflows

### Creating a New Migration

1. **Create the file** in `db/migrations/`:
   ```sql
   -- V4__add_user_roles.sql
   ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'user';
   ```

2. **Test locally**:
   ```bash
   flyway migrate
   ```

3. **Commit and push**:
   ```bash
   git add db/migrations/V4__add_user_roles.sql
   git commit -m "Add user roles column"
   git push
   ```

4. **Team members pull and migrate**:
   ```bash
   git pull
   flyway migrate
   ```

### Checking Migration Status

```bash
# See which migrations have been applied
flyway info

# Output example:
# +-----------+---------+---------------------+------+---------------------+---------+
# | Category  | Version | Description         | Type | Installed On        | State   |
# +-----------+---------+---------------------+------+---------------------+---------+
# | Versioned | 1       | create users table  | SQL  | 2026-02-11 10:00:00 | Success |
# | Versioned | 2       | create products     | SQL  | 2026-02-11 10:00:01 | Success |
# | Versioned | 3       | create orders       | SQL  | 2026-02-11 10:00:02 | Pending |
# +-----------+---------+---------------------+------+---------------------+---------+
```

### Handling Migration Conflicts

If two team members create migrations with the same version number:

1. **Resolve locally**:
   ```bash
   git pull
   # If conflict, rename your migration to next available version
   # e.g., V4__your_change.sql -> V5__your_change.sql
   ```

2. **Re-run migrate**:
   ```bash
   flyway migrate
   ```

### Rolling Back (Emergency Only)

Flyway free edition doesn't support automatic rollback. For manual rollback:

1. **Create an undo migration**:
   ```sql
   -- V5__undo_user_roles.sql
   ALTER TABLE users DROP COLUMN IF EXISTS role;
   ```

2. **Or use Flyway undo** (Teams/Enterprise edition):
   ```bash
   flyway undo
   ```

## 🛠️ Flyway Commands Reference

| Command | Description |
|---------|-------------|
| `flyway migrate` | Migrates the database to the latest version |
| `flyway info` | Prints the status/version of the database |
| `flyway validate` | Validates applied migrations against available ones |
| `flyway clean` | ⚠️ Drops all objects in configured schemas (use with caution!) |
| `flyway repair` | Repairs the schema history table |
| `flyway baseline` | Baselines an existing database at a specific version |

## ⚙️ Configuration Options

### Using Environment Variables (Recommended)

Create a `.env` file (already in `.gitignore`):

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_dev
DB_USER=postgres
DB_PASSWORD=secret123
```

### Using flyway.conf

The `flyway.conf` file contains all configuration. Key settings:

```properties
# Database connection
flyway.url=jdbc:postgresql://localhost:5432/your_database_name
flyway.user=your_username
flyway.password=your_password

# Migration locations
flyway.locations=filesystem:./db/migrations

# Schema management
flyway.schemas=public
flyway.createSchemas=true

# Validation
flyway.validateOnMigrate=true
```

## 🔒 Security Notes

- ⚠️ **Never commit `.env` file** (it's in `.gitignore`)
- ⚠️ **Never commit real passwords** in `flyway.conf`
- ✅ Use environment variables for sensitive data
- ✅ Share `.env.example` as template only

## 🤝 Team Collaboration Best Practices

1. **Always pull before creating new migrations**
   ```bash
   git pull
   flyway info  # Check current state
   # Create your migration with next version number
   ```

2. **Run migrations immediately after pulling**
   ```bash
   git pull
   flyway migrate
   ```

3. **Test migrations locally before pushing**
   ```bash
   flyway migrate
   # Test your application
   git push
   ```

4. **Keep migrations small and focused**
   - One logical change per migration
   - Easier to review and debug

5. **Never modify existing migrations**
   - Once pushed to git, migrations are immutable
   - Create a new migration to fix issues

6. **Document complex migrations**
   - Add comments explaining the purpose
   - Note any manual steps required

## 🐛 Troubleshooting

### "Migration checksum mismatch"
Someone modified an already-applied migration. Options:
```bash
# Option 1: Repair (updates checksums)
flyway repair

# Option 2: Investigate with
flyway info
```

### "Failed to obtain JDBC connection"
- Check PostgreSQL is running: `pg_ctl status` or `sudo service postgresql status`
- Verify credentials in `flyway.conf` or `.env`
- Check database exists: `psql -l`

### "Table already exists"
The database has existing tables. To baseline:
```bash
flyway baseline -baselineVersion=1
flyway migrate
```

### Starting Fresh (Development Only)
```bash
# ⚠️ WARNING: This deletes ALL data!
flyway clean
flyway migrate
```

## 📚 Additional Resources

- [Flyway Documentation](https://flywaydb.org/documentation/)
- [Flyway SQL Migrations](https://flywaydb.org/documentation/concepts/migrations#sql-based-migrations)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 📞 Support

If you encounter issues, please:
1. Check this README
2. Run `flyway info` and share output
3. Contact the team lead
4. Create an issue in the repository

---

**Happy migrating! 🚀**
