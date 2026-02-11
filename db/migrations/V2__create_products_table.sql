-- Migration: Create products table
-- Author: Team
-- Date: 2026-02-11
-- Description: Creates products table for inventory management

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT price_positive CHECK (price >= 0),
    CONSTRAINT stock_non_negative CHECK (stock_quantity >= 0)
);

-- Create index on SKU for faster lookups
CREATE INDEX idx_products_sku ON products(sku);

-- Create index on is_active for filtering
CREATE INDEX idx_products_active ON products(is_active);

-- Add comments
COMMENT ON TABLE products IS 'Product catalog and inventory';
COMMENT ON COLUMN products.sku IS 'Stock Keeping Unit - unique product identifier';
COMMENT ON COLUMN products.price IS 'Product price in decimal format';
