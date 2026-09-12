-- =============================================================================
-- RoomFit Supabase Schema Migration: 001_create_tables.sql
-- Run this in your Supabase Dashboard -> SQL Editor
-- =============================================================================

-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Rooms Table
CREATE TABLE IF NOT EXISTS public.rooms (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    length_ft DOUBLE PRECISION NOT NULL,
    width_ft DOUBLE PRECISION NOT NULL,
    ceiling_height_ft DOUBLE PRECISION DEFAULT 9.0,
    scanned_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    doorways JSONB DEFAULT '[]'::jsonb,
    thumbnail_seed INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure all columns exist if table was previously created with fewer columns
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS ceiling_height_ft DOUBLE PRECISION DEFAULT 9.0;
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS scanned_date TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS doorways JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS thumbnail_seed INTEGER DEFAULT 1;
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- Enable RLS for rooms
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'rooms' AND policyname = 'Users can select own rooms') THEN
        CREATE POLICY "Users can select own rooms" ON public.rooms FOR SELECT USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'rooms' AND policyname = 'Users can insert own rooms') THEN
        CREATE POLICY "Users can insert own rooms" ON public.rooms FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'rooms' AND policyname = 'Users can update own rooms') THEN
        CREATE POLICY "Users can update own rooms" ON public.rooms FOR UPDATE USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'rooms' AND policyname = 'Users can delete own rooms') THEN
        CREATE POLICY "Users can delete own rooms" ON public.rooms FOR DELETE USING (auth.uid() = user_id);
    END IF;
END $$;


-- 2. Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    source TEXT NOT NULL,
    category TEXT NOT NULL,
    length_in DOUBLE PRECISION NOT NULL,
    width_in DOUBLE PRECISION NOT NULL,
    height_in DOUBLE PRECISION NOT NULL,
    confidence TEXT NOT NULL,
    image_url TEXT,
    barcode TEXT,
    product_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure all columns exist
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS source TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS length_in DOUBLE PRECISION;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS width_in DOUBLE PRECISION;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS height_in DOUBLE PRECISION;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS confidence TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS barcode TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS product_url TEXT;
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- Enable RLS for products
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'products' AND policyname = 'Users can select own products') THEN
        CREATE POLICY "Users can select own products" ON public.products FOR SELECT USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'products' AND policyname = 'Users can insert own products') THEN
        CREATE POLICY "Users can insert own products" ON public.products FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'products' AND policyname = 'Users can update own products') THEN
        CREATE POLICY "Users can update own products" ON public.products FOR UPDATE USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'products' AND policyname = 'Users can delete own products') THEN
        CREATE POLICY "Users can delete own products" ON public.products FOR DELETE USING (auth.uid() = user_id);
    END IF;
END $$;


-- 3. Fit Checks / Wishlist Table
CREATE TABLE IF NOT EXISTS public.fit_checks (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id TEXT,
    product_data JSONB,
    room_id TEXT NOT NULL,
    room_name TEXT NOT NULL,
    position_x DOUBLE PRECISION DEFAULT 0.0,
    position_y DOUBLE PRECISION DEFAULT 0.0,
    rotation_deg DOUBLE PRECISION DEFAULT 0.0,
    fit_status TEXT NOT NULL,
    clearance_inches DOUBLE PRECISION DEFAULT 0.0,
    obstruction_reason TEXT,
    timestamp TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure all columns exist
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS product_id TEXT;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS product_data JSONB;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS room_id TEXT;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS room_name TEXT;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS position_x DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS position_y DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS rotation_deg DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS fit_status TEXT;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS clearance_inches DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS obstruction_reason TEXT;
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS timestamp TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.fit_checks ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- Enable RLS for fit_checks
ALTER TABLE public.fit_checks ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'fit_checks' AND policyname = 'Users can select own fit checks') THEN
        CREATE POLICY "Users can select own fit checks" ON public.fit_checks FOR SELECT USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'fit_checks' AND policyname = 'Users can insert own fit checks') THEN
        CREATE POLICY "Users can insert own fit checks" ON public.fit_checks FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'fit_checks' AND policyname = 'Users can update own fit checks') THEN
        CREATE POLICY "Users can update own fit checks" ON public.fit_checks FOR UPDATE USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'fit_checks' AND policyname = 'Users can delete own fit checks') THEN
        CREATE POLICY "Users can delete own fit checks" ON public.fit_checks FOR DELETE USING (auth.uid() = user_id);
    END IF;
END $$;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_rooms_user_id ON public.rooms(user_id);
CREATE INDEX IF NOT EXISTS idx_products_user_id ON public.products(user_id);
CREATE INDEX IF NOT EXISTS idx_fit_checks_user_id ON public.fit_checks(user_id);
CREATE INDEX IF NOT EXISTS idx_fit_checks_room_id ON public.fit_checks(room_id);

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Auto-confirm all registered test users for development
UPDATE auth.users 
SET email_confirmed_at = now() 
WHERE email_confirmed_at IS NULL;
