# Flyway Quick Reference

## 📋 Common Commands

| Command | Description | When to Use |
|---------|-------------|-------------|
| `flyway migrate` | Run pending migrations | After pulling changes, creating new migration |
| `flyway info` | Show migration status | Check what's applied, what's pending |
| `flyway validate` | Validate migrations | Before committing, troubleshooting |
| `flyway repair` | Fix schema history | After checksum mismatch |
| `flyway clean` | 🔴 Drop all objects | Fresh start (dev only!) |

## 🚀 Typical Workflows

### Daily Work
```bash
# Start of day
git pull
flyway migrate

# End of day
git push
# Team members will: git pull && flyway migrate
```

### Creating New Migration
```powershell
# Windows
.\scripts\new-migration.ps1 -Description "your_change"

# Manual
# 1. Create: db/migrations/V{next}__description.sql
# 2. Write SQL
# 3. Test: flyway migrate
# 4. Commit & push
```

### After Pulling Changes
```bash
git pull
flyway info      # See what's new
flyway migrate   # Apply changes
```

## 🐛 Troubleshooting

| Error | Solution |
|-------|----------|
| "Migration checksum mismatch" | `flyway repair` |
| "Failed to obtain JDBC connection" | Check PostgreSQL running, verify credentials |
| "Table already exists" | `flyway baseline` or `flyway clean && flyway migrate` |
| Version conflict | Rename your migration to next available version |

## 📁 File Structure

```
db/
├── migrations/          # Schema changes (V1, V2, V3...)
│   ├── V1__create_users_table.sql
│   ├── V2__create_products_table.sql
│   └── V3__add_user_roles.sql
└── seeds/              # Test data (V100+)
    ├── V100__seed_users.sql
    └── V101__seed_products.sql
```

## 📝 Migration Template

```sql
-- Migration: [Purpose]
-- Author: [Your Name]
-- Date: [YYYY-MM-DD]
-- Description: [Detailed description]

-- Your SQL here
CREATE TABLE IF NOT EXISTS example (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_example_name ON example(name);

COMMENT ON TABLE example IS 'Description of table';
```

## 🔒 Golden Rules

1. ✅ **Never modify pushed migrations**
2. ✅ **Always pull before creating new migration**
3. ✅ **Test locally before pushing**
4. ✅ **Use IF NOT EXISTS when safe**
5. ❌ **Don't commit sensitive data**
6. ❌ **Don't use `flyway clean` in production**

## 🎯 Migration Naming

**Format**: `V{version}__{description}.sql`

Examples:
- `V1__create_users_table.sql` ✅
- `V2__add_email_index.sql` ✅
- `V2.1__fix_email_constraint.sql` ✅
- `v3__create_orders.sql` ❌ (lowercase v)
- `V3_create_orders.sql` ❌ (single underscore)

## 🔗 Quick Links

- [Full README](README.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Flyway Docs](https://flywaydb.org/documentation/)
