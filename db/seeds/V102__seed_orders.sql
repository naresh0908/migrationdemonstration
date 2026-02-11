-- Seed Data: Sample orders
-- Description: Inserts sample order data for development/testing

-- Insert sample orders
INSERT INTO orders (user_id, order_number, status, total_amount) VALUES
(2, 'ORD-2026-001', 'delivered', 1329.98),
(3, 'ORD-2026-002', 'shipped', 219.97),
(4, 'ORD-2026-003', 'processing', 549.98),
(2, 'ORD-2026-004', 'pending', 89.99),
(3, 'ORD-2026-005', 'delivered', 399.99)
ON CONFLICT (order_number) DO NOTHING;

-- Insert order items (assuming order IDs 1-5 were created above)
-- Note: You may need to adjust the order_id values based on your actual data
INSERT INTO order_items (order_id, product_id, quantity, price_at_time) 
SELECT 
    o.id,
    p.id,
    q.quantity,
    p.price
FROM orders o
CROSS JOIN (VALUES 
    ('ORD-2026-001', 'TECH-LAP-001', 1),
    ('ORD-2026-001', 'TECH-MOU-001', 1),
    ('ORD-2026-002', 'TECH-KEY-001', 1),
    ('ORD-2026-002', 'TECH-HUB-001', 1),
    ('ORD-2026-002', 'TECH-STD-001', 4),
    ('ORD-2026-003', 'TECH-HDP-001', 1),
    ('ORD-2026-003', 'TECH-SSD-001', 1),
    ('ORD-2026-003', 'TECH-CAM-001', 1),
    ('ORD-2026-004', 'TECH-KEY-001', 1),
    ('ORD-2026-005', 'TECH-MON-001', 1)
) AS q(order_number, sku, quantity)
JOIN products p ON p.sku = q.sku
WHERE o.order_number = q.order_number
ON CONFLICT DO NOTHING;
