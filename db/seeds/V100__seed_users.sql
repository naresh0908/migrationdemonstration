-- Seed Data: Sample users
-- Description: Inserts sample user data for development/testing
-- Note: Passwords are hashed (bcrypt). Plain text examples:
--   - admin@example.com: "admin123"
--   - john.doe@example.com: "password123"
--   - jane.smith@example.com: "password123"

INSERT INTO users (email, username, password_hash, first_name, last_name, is_active) VALUES
('admin@example.com', 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin', 'User', true),
('john.doe@example.com', 'johndoe', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'John', 'Doe', true),
('jane.smith@example.com', 'janesmith', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jane', 'Smith', true),
('bob.wilson@example.com', 'bobwilson', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Bob', 'Wilson', true),
('alice.brown@example.com', 'alicebrown', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Alice', 'Brown', false)
ON CONFLICT (email) DO NOTHING;
