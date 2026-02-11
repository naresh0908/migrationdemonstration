-- Seed Data: Sample products
-- Description: Inserts sample product data for development/testing

INSERT INTO products (name, description, sku, price, stock_quantity, is_active) VALUES
('Laptop Pro 15"', 'High-performance laptop with 15-inch display, 16GB RAM, 512GB SSD', 'TECH-LAP-001', 1299.99, 50, true),
('Wireless Mouse', 'Ergonomic wireless mouse with 6 buttons and adjustable DPI', 'TECH-MOU-001', 29.99, 200, true),
('Mechanical Keyboard', 'RGB mechanical keyboard with blue switches', 'TECH-KEY-001', 89.99, 75, true),
('USB-C Hub', '7-in-1 USB-C hub with HDMI, USB 3.0, and SD card reader', 'TECH-HUB-001', 49.99, 150, true),
('Noise-Cancelling Headphones', 'Premium wireless headphones with active noise cancellation', 'TECH-HDP-001', 299.99, 30, true),
('Webcam HD', '1080p webcam with built-in microphone', 'TECH-CAM-001', 79.99, 100, true),
('Phone Stand', 'Adjustable aluminum phone stand', 'TECH-STD-001', 19.99, 300, true),
('Portable SSD 1TB', 'Fast external SSD with USB-C connection', 'TECH-SSD-001', 149.99, 60, true),
('Monitor 27"', '27-inch 4K monitor with IPS panel', 'TECH-MON-001', 399.99, 40, true),
('Desk Lamp LED', 'Smart LED desk lamp with brightness control', 'TECH-LMP-001', 39.99, 120, true)
ON CONFLICT (sku) DO NOTHING;
