# Contributing to Database Migrations

Thank you for contributing to our database schema! This guide will help you work with migrations safely and effectively.

## 🎯 Quick Checklist

Before creating a migration:
- [ ] Pull latest changes from main branch
- [ ] Check current migration status (`flyway info`)
- [ ] Identify the next version number
- [ ] Plan your changes (discuss with team if major)

Before committing:
- [ ] Test migration locally
- [ ] Verify application works with changes
- [ ] Add descriptive commit message
- [ ] Ensure migration is idempotent (can run multiple times safely)

## 📝 Creating a New Migration

### Option 1: Use the Helper Script (Windows)

```powershell
.\scripts\new-migration.ps1 -Description "add_user_roles"
```

This automatically:
- Determines the next version number
- Creates a properly named file
- Adds a template with your description

### Option 2: Manual Creation

1. **Determine next version**:
   ```bash
   # Look at existing files in db/migrations/
   # If last file is V3__*, create V4__*
   ```

2. **Create file**: `db/migrations/V{X}__{description}.sql`
   ```sql
   -- V4__add_user_roles.sql
   ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'user';
   CREATE INDEX idx_users_role ON users(role);
   ```

3. **Test locally**:
   ```bash
   flyway migrate
   flyway info
   ```

## 🔒 Migration Rules

### DO ✅

1. **Keep migrations immutable**
   - Never edit a migration after it's been committed and pushed
   - Create a new migration to fix issues

2. **Make migrations idempotent** (when possible)
   ```sql
   -- Good: Won't fail if run twice
   CREATE TABLE IF NOT EXISTS users (...);
   ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
   
   -- Better for production:
   DO $$
   BEGIN
       IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                      WHERE table_name='users' AND column_name='email') THEN
           ALTER TABLE users ADD COLUMN email VARCHAR(255);
       END IF;
   END $$;
   ```

3. **Add comments and documentation**
   ```sql
   -- Migration: Add user authentication
   -- Author: John Doe
   -- Date: 2026-02-11
   -- Description: Adds password and email fields for user login
   
   COMMENT ON COLUMN users.password_hash IS 'Bcrypt hashed password';
   ```

4. **Use transactions** (implicit in Flyway for PostgreSQL)
   ```sql
   -- Flyway wraps each migration in a transaction by default
   -- All changes succeed or all fail
   ```

5. **Test with real data** (if safe)
   ```sql
   -- Create sample data to test your migration
   INSERT INTO users (email, username) VALUES ('test@test.com', 'testuser');
   -- Verify constraints work
   ```

6. **Include indexes** for foreign keys and frequently queried columns
   ```sql
   CREATE INDEX idx_orders_user_id ON orders(user_id);
   CREATE INDEX idx_orders_created_at ON orders(created_at);
   ```

### DON'T ❌

1. **Modify existing migrations**
   ```sql
   ❌ Editing V1__create_users.sql after it's been applied
   ✅ Create V5__modify_users_table.sql instead
   ```

2. **Use database-specific features** without documentation
   ```sql
   ❌ Using features that might not work on team members' PostgreSQL versions
   ✅ Target PostgreSQL 12+ features (document minimum version)
   ```

3. **Skip version numbers arbitrarily**
   ```sql
   ❌ V1, V2, V8 (missing V3-V7)
   ✅ V1, V2, V3, V4 (sequential)
   ⚠️ V1, V2, V2.1, V3 (OK, but use sparingly)
   ```

4. **Include sensitive data** in migrations
   ```sql
   ❌ INSERT INTO users VALUES ('admin', 'password123');
   ⚠️ Use seed files for test data (V100+ versions)
   ```

5. **Make breaking changes** without warning
   ```sql
   ❌ DROP TABLE users; -- without team discussion
   ✅ Communicate with team first, plan rollout
   ```

## 🌳 Git Workflow

### Standard Flow

1. **Pull latest**:
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b feature/add-user-roles
   ```

3. **Create and test migration**:
   ```bash
   .\scripts\new-migration.ps1 -Description "add_user_roles"
   # Edit the file
   flyway migrate
   # Test your application
   ```

4. **Commit**:
   ```bash
   git add db/migrations/V4__add_user_roles.sql
   git commit -m "Add role column to users table"
   ```

5. **Push and create PR**:
   ```bash
   git push origin feature/add-user-roles
   # Create Pull Request on GitHub
   ```

6. **After merge, team members**:
   ```bash
   git pull origin main
   flyway migrate
   ```

### Handling Conflicts

If two people create V4 simultaneously:

**Person A** (merged first):
- V4__add_user_roles.sql ✅

**Person B** (PR conflicts):
1. Rename their migration:
   ```bash
   git mv db/migrations/V4__add_product_categories.sql \
          db/migrations/V5__add_product_categories.sql
   ```
2. Update version in file:
   ```sql
   -- V5__add_product_categories.sql
   ```
3. Commit and push update

## 🧪 Testing Migrations

### Local Testing

1. **Test fresh database**:
   ```bash
   # Clean and migrate from scratch
   flyway clean  # ⚠️ Deletes all data!
   flyway migrate
   ```

2. **Test incremental**:
   ```bash
   # From current state
   flyway migrate
   ```

3. **Verify data**:
   ```sql
   -- Connect to database
   psql -d your_database_name
   
   -- Check tables
   \dt
   
   -- Check columns
   \d users
   
   -- Query data
   SELECT * FROM users LIMIT 5;
   ```

### Test Scenarios

For a migration adding a NOT NULL column:
```sql
-- ❌ Bad: Will fail if table has data
ALTER TABLE users ADD COLUMN phone VARCHAR(20) NOT NULL;

-- ✅ Good: Add as nullable first
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
-- Later, after data migration:
-- ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

-- ✅ Better: Add with default
ALTER TABLE users ADD COLUMN phone VARCHAR(20) NOT NULL DEFAULT '';
```

## 📊 Migration Complexity Levels

### Simple (✅ Low risk, quick review)
- Adding nullable columns
- Creating indexes
- Adding comments
- Inserting seed data

### Medium (⚠️ Moderate risk, careful review)
- Adding foreign keys
- Modifying column types
- Adding NOT NULL columns with defaults
- Creating triggers

### Complex (🔴 High risk, team discussion required)
- Dropping columns or tables
- Changing primary keys
- Data migrations with transformations
- Schema renames affecting application code

## 📞 Getting Help

### Before Creating Migration

- Discuss complex changes in team chat
- Review similar migrations in `db/migrations/`
- Check PostgreSQL documentation

### During Issues

1. **Review error message**:
   ```bash
   flyway info  # Check status
   flyway validate  # Check for issues
   ```

2. **Common fixes**:
   ```bash
   # Checksum mismatch
   flyway repair
   
   # Missing migration
   git pull
   flyway migrate
   ```

3. **Ask for help**:
   - Share `flyway info` output
   - Describe what you were trying to do
   - Include error message

## 📚 Additional Resources

- [Flyway Best Practices](https://flywaydb.org/documentation/concepts/migrations#best-practices)
- [PostgreSQL ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html)
- [SQL Style Guide](https://www.sqlstyle.guide/)

---

**Remember**: Migrations are permanent. When in doubt, ask the team! 🤝
