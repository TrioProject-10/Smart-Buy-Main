-- ============================================
-- SMART BUY - COMPREHENSIVE SUPABASE SCHEMA
-- ============================================
-- Enhanced schema for managing products, reviews, and users
-- Supports all product categories: Electronics, Home Appliances, Footwear, etc.
-- Run these commands in your Supabase SQL editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
-- User profile information linked to auth.users
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    email TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    phone TEXT,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ============================================
-- 2. CATEGORIES TABLE
-- ============================================
-- Product categories for organization
CREATE TABLE IF NOT EXISTS public.categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    parent_category_id INTEGER REFERENCES public.categories(id) ON DELETE SET NULL,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ============================================
-- 3. BRANDS TABLE
-- ============================================
-- Product brands/manufacturers
CREATE TABLE IF NOT EXISTS public.brands (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    logo_url TEXT,
    website_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ============================================
-- 4. PRODUCTS TABLE (ENHANCED)
-- ============================================
-- Comprehensive product information
CREATE TABLE IF NOT EXISTS public.products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    short_description TEXT,
    
    -- Pricing
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    discount_percentage INTEGER,
    currency TEXT DEFAULT 'INR',
    
    -- Images
    image_url TEXT NOT NULL,
    image_urls TEXT[], -- Array of multiple product images
    
    -- Categorization
    category_id INTEGER REFERENCES public.categories(id) ON DELETE SET NULL,
    brand_id INTEGER REFERENCES public.brands(id) ON DELETE SET NULL,
    
    -- Product Details
    model_number TEXT,
    sku TEXT UNIQUE,
    specifications JSONB, -- Flexible JSON for product specs
    features TEXT[],
    tags TEXT[],
    
    -- Inventory
    stock_quantity INTEGER DEFAULT 0,
    is_in_stock BOOLEAN DEFAULT true,
    
    -- External Links
    amazon_url TEXT,
    flipkart_url TEXT,
    official_url TEXT,
    
    -- Ratings & Reviews
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    is_trending BOOLEAN DEFAULT false,
    
    -- SEO
    meta_title TEXT,
    meta_description TEXT,
    meta_keywords TEXT[],
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    
    -- Constraints
    CONSTRAINT positive_price CHECK (price >= 0),
    CONSTRAINT valid_rating CHECK (average_rating >= 0 AND average_rating <= 5)
);

-- ============================================
-- 5. REVIEWS TABLE (ENHANCED)
-- ============================================
-- User reviews for products
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
    product_id INTEGER REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    
    -- Review Content
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title TEXT,
    review_text TEXT NOT NULL,
    
    -- Review Details
    pros TEXT[],
    cons TEXT[],
    
    -- Verification
    is_verified_purchase BOOLEAN DEFAULT false,
    
    -- Helpfulness
    helpful_count INTEGER DEFAULT 0,
    unhelpful_count INTEGER DEFAULT 0,
    
    -- Images
    review_images TEXT[],
    
    -- Status
    is_approved BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    
    -- Constraints
    UNIQUE(user_id, product_id) -- One review per user per product
);

-- ============================================
-- 6. REVIEW VOTES TABLE
-- ============================================
-- Track which users found reviews helpful
CREATE TABLE IF NOT EXISTS public.review_votes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID REFERENCES public.reviews(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
    is_helpful BOOLEAN NOT NULL, -- true = helpful, false = unhelpful
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    
    UNIQUE(review_id, user_id) -- One vote per user per review
);

-- ============================================
-- 7. WISHLISTS TABLE
-- ============================================
-- User wishlists/favorites
CREATE TABLE IF NOT EXISTS public.wishlists (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
    product_id INTEGER REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    
    UNIQUE(user_id, product_id)
);

-- ============================================
-- 8. PRODUCT VIEWS TABLE
-- ============================================
-- Track product views for analytics
CREATE TABLE IF NOT EXISTS public.product_views (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id INTEGER REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users ON DELETE SET NULL,
    ip_address INET,
    user_agent TEXT,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
-- Products indexes
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_brand ON public.products(brand_id);
CREATE INDEX IF NOT EXISTS idx_products_slug ON public.products(slug);
CREATE INDEX IF NOT EXISTS idx_products_active ON public.products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_featured ON public.products(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_trending ON public.products(is_trending);
CREATE INDEX IF NOT EXISTS idx_products_rating ON public.products(average_rating DESC);
CREATE INDEX IF NOT EXISTS idx_products_price ON public.products(price);

-- Reviews indexes
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON public.reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON public.reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON public.reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.reviews(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_approved ON public.reviews(is_approved);

-- Categories indexes
CREATE INDEX IF NOT EXISTS idx_categories_slug ON public.categories(slug);
CREATE INDEX IF NOT EXISTS idx_categories_active ON public.categories(is_active);
CREATE INDEX IF NOT EXISTS idx_categories_parent ON public.categories(parent_category_id);

-- Brands indexes
CREATE INDEX IF NOT EXISTS idx_brands_slug ON public.brands(slug);
CREATE INDEX IF NOT EXISTS idx_brands_active ON public.brands(is_active);

-- Other indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_wishlists_user ON public.wishlists(user_id);
CREATE INDEX IF NOT EXISTS idx_product_views_product ON public.product_views(product_id);
CREATE INDEX IF NOT EXISTS idx_product_views_viewed_at ON public.product_views(viewed_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_views ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES - PROFILES
-- ============================================
CREATE POLICY "Public profiles are viewable by everyone" 
ON public.profiles FOR SELECT 
USING (true);

CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- ============================================
-- RLS POLICIES - CATEGORIES
-- ============================================
CREATE POLICY "Categories are viewable by everyone" 
ON public.categories FOR SELECT 
USING (is_active = true);

-- ============================================
-- RLS POLICIES - BRANDS
-- ============================================
CREATE POLICY "Brands are viewable by everyone" 
ON public.brands FOR SELECT 
USING (is_active = true);

-- ============================================
-- RLS POLICIES - PRODUCTS
-- ============================================
CREATE POLICY "Active products are viewable by everyone" 
ON public.products FOR SELECT 
USING (is_active = true);

-- Note: Insert/Update/Delete policies for products should be restricted to admin users
-- You can add a role-based policy here if needed

-- ============================================
-- RLS POLICIES - REVIEWS
-- ============================================
CREATE POLICY "Approved reviews are viewable by everyone" 
ON public.reviews FOR SELECT 
USING (is_approved = true);

CREATE POLICY "Users can insert their own reviews" 
ON public.reviews FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews" 
ON public.reviews FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews" 
ON public.reviews FOR DELETE 
USING (auth.uid() = user_id);

-- ============================================
-- RLS POLICIES - REVIEW VOTES
-- ============================================
CREATE POLICY "Review votes are viewable by everyone" 
ON public.review_votes FOR SELECT 
USING (true);

CREATE POLICY "Users can vote on reviews" 
ON public.review_votes FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own votes" 
ON public.review_votes FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own votes" 
ON public.review_votes FOR DELETE 
USING (auth.uid() = user_id);

-- ============================================
-- RLS POLICIES - WISHLISTS
-- ============================================
CREATE POLICY "Users can view their own wishlist" 
ON public.wishlists FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can add to their wishlist" 
ON public.wishlists FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their wishlist" 
ON public.wishlists FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete from their wishlist" 
ON public.wishlists FOR DELETE 
USING (auth.uid() = user_id);

-- ============================================
-- RLS POLICIES - PRODUCT VIEWS
-- ============================================
CREATE POLICY "Anyone can insert product views" 
ON public.product_views FOR INSERT 
WITH CHECK (true);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update product rating when review is added/updated
CREATE OR REPLACE FUNCTION public.update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.products
    SET 
        average_rating = (
            SELECT COALESCE(AVG(rating), 0)
            FROM public.reviews
            WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)
            AND is_approved = true
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM public.reviews
            WHERE product_id = COALESCE(NEW.product_id, OLD.product_id)
            AND is_approved = true
        ),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.product_id, OLD.product_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update review helpfulness counts
CREATE OR REPLACE FUNCTION public.update_review_helpfulness()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.reviews
    SET 
        helpful_count = (
            SELECT COUNT(*)
            FROM public.review_votes
            WHERE review_id = COALESCE(NEW.review_id, OLD.review_id)
            AND is_helpful = true
        ),
        unhelpful_count = (
            SELECT COUNT(*)
            FROM public.review_votes
            WHERE review_id = COALESCE(NEW.review_id, OLD.review_id)
            AND is_helpful = false
        )
    WHERE id = COALESCE(NEW.review_id, OLD.review_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to automatically create a profile when a user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to handle updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Triggers for updated_at
CREATE TRIGGER handle_updated_at_profiles BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_categories BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_brands BEFORE UPDATE ON public.brands
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_products BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_updated_at_reviews BEFORE UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Triggers for product rating updates
DROP TRIGGER IF EXISTS update_product_rating_on_insert ON public.reviews;
CREATE TRIGGER update_product_rating_on_insert
    AFTER INSERT ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_product_rating();

DROP TRIGGER IF EXISTS update_product_rating_on_update ON public.reviews;
CREATE TRIGGER update_product_rating_on_update
    AFTER UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_product_rating();

DROP TRIGGER IF EXISTS update_product_rating_on_delete ON public.reviews;
CREATE TRIGGER update_product_rating_on_delete
    AFTER DELETE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_product_rating();

-- Triggers for review helpfulness updates
DROP TRIGGER IF EXISTS update_review_helpfulness_on_insert ON public.review_votes;
CREATE TRIGGER update_review_helpfulness_on_insert
    AFTER INSERT ON public.review_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_review_helpfulness();

DROP TRIGGER IF EXISTS update_review_helpfulness_on_update ON public.review_votes;
CREATE TRIGGER update_review_helpfulness_on_update
    AFTER UPDATE ON public.review_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_review_helpfulness();

DROP TRIGGER IF EXISTS update_review_helpfulness_on_delete ON public.review_votes;
CREATE TRIGGER update_review_helpfulness_on_delete
    AFTER DELETE ON public.review_votes
    FOR EACH ROW EXECUTE FUNCTION public.update_review_helpfulness();

-- ============================================
-- SEED DATA - CATEGORIES
-- ============================================
INSERT INTO public.categories (name, slug, description, display_order) VALUES
('Electronics', 'electronics', 'Latest gadgets and electronic devices', 1),
('Smartphones', 'smartphones', 'Mobile phones and accessories', 2),
('Laptops & Computers', 'laptops-computers', 'Computers, laptops, and peripherals', 3),
('Home Appliances', 'home-appliances', 'Essential appliances for your home', 4),
('Fashion & Lifestyle', 'fashion-lifestyle', 'Clothing, accessories, and lifestyle products', 5),
('Footwear', 'footwear', 'Shoes, sneakers, and sandals', 6),
('Sports & Fitness', 'sports-fitness', 'Sports equipment and fitness gear', 7),
('Kitchen Appliances', 'kitchen-appliances', 'Kitchen tools and appliances', 8),
('Audio & Headphones', 'audio-headphones', 'Headphones, speakers, and audio equipment', 9),
('Wearables', 'wearables', 'Smartwatches, fitness trackers, and wearable tech', 10)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- SEED DATA - BRANDS
-- ============================================
INSERT INTO public.brands (name, slug) VALUES
('Apple', 'apple'),
('Samsung', 'samsung'),
('OnePlus', 'oneplus'),
('Google', 'google'),
('Realme', 'realme'),
('Xiaomi', 'xiaomi'),
('Redmi', 'redmi'),
('Nothing', 'nothing'),
('Vivo', 'vivo'),
('Adidas', 'adidas'),
('Nike', 'nike'),
('Puma', 'puma'),
('Reebok', 'reebok'),
('Skechers', 'skechers'),
('Dyson', 'dyson'),
('LG', 'lg'),
('Philips', 'philips'),
('Bajaj', 'bajaj'),
('Prestige', 'prestige'),
('IFB', 'ifb'),
('boAt', 'boat'),
('Acer', 'acer'),
('Lunar Vista', 'lunar-vista')
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- SEED DATA - PRODUCTS (SMARTPHONES)
-- ============================================
INSERT INTO public.products (name, slug, description, price, image_url, category_id, brand_id, amazon_url, is_featured) VALUES
(
    'Apple iPhone 15 Pro',
    'apple-iphone-15-pro',
    'Latest iPhone with A17 Pro chip, titanium design, and advanced camera system',
    135000,
    '/Images/smartphones/Iphone_15-Pro.jpg',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'apple'),
    'https://amazon.in',
    true
),
(
    'Samsung Galaxy S23 Ultra',
    'samsung-galaxy-s23-ultra',
    'Premium Android flagship with S Pen, 200MP camera, and powerful performance',
    125000,
    '/Images/smartphones/Samsung Galaxy S23 Ultra.jpeg',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'samsung'),
    'https://amazon.in',
    true
),
(
    'OnePlus 12',
    'oneplus-12',
    'Flagship killer with Snapdragon 8 Gen 3 and Hasselblad camera',
    68000,
    '/Images/smartphones/OnePlus 12.webp',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'oneplus'),
    'https://amazon.in',
    false
),
(
    'Google Pixel 8 Pro',
    'google-pixel-8-pro',
    'Best-in-class AI features and pure Android experience',
    106000,
    '/Images/smartphones/Google Pixel 8 Pro.jpg',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'google'),
    'https://amazon.in',
    true
),
(
    'Realme GT 5',
    'realme-gt-5',
    'Performance-focused smartphone with great value',
    45000,
    '/Images/smartphones/Realme GT 5.jpeg',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'realme'),
    'https://amazon.in',
    false
),
(
    'Redmi Note 13 Pro+',
    'redmi-note-13-pro-plus',
    'Feature-packed mid-range smartphone with excellent camera',
    32000,
    '/Images/smartphones/Redmi Note 13 Pro+.jpg',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'redmi'),
    'https://amazon.in',
    false
),
(
    'Nothing Phone (2)',
    'nothing-phone-2',
    'Unique design with Glyph Interface and flagship specs',
    49999,
    '/Images/smartphones/Nothing Phone (2).jpg',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'nothing'),
    'https://amazon.in',
    false
),
(
    'Vivo X100 Pro',
    'vivo-x100-pro',
    'Photography-focused flagship with ZEISS optics',
    89999,
    '/Images/smartphones/Vivo X100 Pro.webp',
    (SELECT id FROM public.categories WHERE slug = 'smartphones'),
    (SELECT id FROM public.brands WHERE slug = 'vivo'),
    'https://amazon.in',
    false
)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- SEED DATA - PRODUCTS (FOOTWEAR)
-- ============================================
INSERT INTO public.products (name, slug, description, price, image_url, category_id, brand_id, amazon_url) VALUES
(
    'Adidas Runner: Supernova Solution 2.0',
    'adidas-runner-supernova-solution',
    'Comfortable running shoes with excellent grip and cushioning',
    25000,
    '/Images/Shoes/Adidas-Runner-supernova-solution-2.0-running-shoes.avif',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'adidas'),
    'https://amazon.in'
),
(
    'Nike Flex',
    'nike-flex',
    'Flexible and durable athletic shoes for all-day comfort',
    15000,
    '/Images/nikeflex.avif',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'nike'),
    'https://amazon.in'
),
(
    'Puma Casual: X-Ray 2 Square Retro Style Sneakers',
    'puma-casual-x-ray-2-square',
    'Stylish retro sneakers for casual wear',
    6800,
    '/Images/Shoes/Puma-Casual-X-Ray-2-Square-Retro-Style-Sneakers.avif',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'puma'),
    'https://amazon.in'
),
(
    'Puma Sporty: Skyrocket Lite Running Shoes',
    'puma-sporty-skyrocket-lite',
    'Lightweight running shoes for performance',
    4999,
    '/Images/Shoes/Puma-Sporty-Skyrocket-Lite-Men\'s-Running-Shoes.avif',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'puma'),
    'https://amazon.in'
),
(
    'Reebok Sport FLYLITE QUICKGLIDE Running Shoes',
    'reebok-sport-flylite-quickglide',
    'Premium running shoes with advanced cushioning',
    10600,
    '/Images/shoes/Reebok-Sport-FLYLITE-QUICKGLIDE-M-Running-Shoes.webp',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'reebok'),
    'https://amazon.in'
),
(
    'Reebok Classic',
    'reebok-classic',
    'Timeless classic sneakers for everyday style',
    8999,
    '/Images/shoes/Reebok-Classic.webp',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'reebok'),
    'https://amazon.in'
),
(
    'Skechers Sprint',
    'skechers-sprint',
    'Lightweight sports shoes for daily wear',
    10000,
    '/Images/skechers.webp',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'skechers'),
    'https://amazon.in'
),
(
    'Nike Zoom Rival Fly',
    'nike-zoom-rival-fly',
    'Racing shoes for speed and performance',
    4500,
    '/Images/shoes/Nike-Zoom-Rival-Fly.webp',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    (SELECT id FROM public.brands WHERE slug = 'nike'),
    'https://amazon.in'
),
(
    'Casual Canvas',
    'casual-canvas',
    'Stylish canvas shoes for casual outings',
    12000,
    '/Images/casual canvas.avif',
    (SELECT id FROM public.categories WHERE slug = 'footwear'),
    NULL,
    'https://amazon.in'
)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- SEED DATA - PRODUCTS (HOME APPLIANCES)
-- ============================================
INSERT INTO public.products (name, slug, description, price, image_url, category_id, brand_id, amazon_url) VALUES
(
    'Dyson V15 Vacuum',
    'dyson-v15-vacuum',
    'Powerful cordless vacuum with laser detection',
    65000,
    '/Images/homeappliances/Dyson V15 Vacuum.jpeg',
    (SELECT id FROM public.categories WHERE slug = 'home-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'dyson'),
    'https://amazon.in'
),
(
    'Samsung 265L Refrigerator',
    'samsung-265l-refrigerator',
    'Energy-efficient refrigerator with convertible mode',
    38500,
    '/Images/homeappliances/Samsung 265L Refrigerator.avif',
    (SELECT id FROM public.categories WHERE slug = 'home-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'samsung'),
    'https://amazon.in'
),
(
    'Philips Air Fryer XXL',
    'philips-air-fryer-xxl',
    'Large capacity air fryer for healthy cooking',
    17999,
    '/Images/homeappliances/Philips Air Fryer XXL.webp',
    (SELECT id FROM public.categories WHERE slug = 'kitchen-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'philips'),
    'https://amazon.in'
),
(
    'LG 7kg Front Load Washer',
    'lg-7kg-front-load-washer',
    'Energy-efficient washing machine with AI DD',
    29500,
    '/Images/homeappliances/LG 7kg Front Load Washer.webp',
    (SELECT id FROM public.categories WHERE slug = 'home-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'lg'),
    'https://amazon.in'
),
(
    'Bajaj GX15 Mixer Grinder',
    'bajaj-gx15-mixer-grinder',
    '750W mixer grinder with 3 jars',
    3500,
    '/Images/homeappliances/Bajaj GX15 Mixer Grinder.webp',
    (SELECT id FROM public.categories WHERE slug = 'kitchen-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'bajaj'),
    'https://amazon.in'
),
(
    'Samsung 23L Browning Plus Grill Microwave Oven',
    'samsung-23l-microwave-oven',
    'Microwave oven with grill and browning function',
    8999,
    '/Images/homeappliances/23 L Browning Plus Grill Microwave Oven MG23A3515AK.avif',
    (SELECT id FROM public.categories WHERE slug = 'kitchen-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'samsung'),
    'https://amazon.in'
),
(
    'Prestige PIC 6.1 V3 2200W Induction Cooktop',
    'prestige-pic-6-1-v3-induction',
    'Fast and efficient induction cooktop',
    2499,
    '/Images/homeappliances/Prestige PIC 6.1 V3 2200W Induction Cooktop.webp',
    (SELECT id FROM public.categories WHERE slug = 'kitchen-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'prestige'),
    'https://amazon.in'
),
(
    'IFB 12 Place Dishwasher',
    'ifb-12-place-dishwasher',
    'Efficient dishwasher with multiple wash programs',
    35000,
    '/Images/homeappliances/IFB 12 Place Dishwasher.avif',
    (SELECT id FROM public.categories WHERE slug = 'kitchen-appliances'),
    (SELECT id FROM public.brands WHERE slug = 'ifb'),
    'https://amazon.in'
)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- SEED DATA - PRODUCTS (ELECTRONICS)
-- ============================================
INSERT INTO public.products (name, slug, description, price, image_url, category_id, brand_id, amazon_url, is_featured) VALUES
(
    'boAt Wireless Headphones',
    'boat-wireless-headphones',
    'Premium wireless headphones with superior sound quality and long battery life',
    3000,
    '/Images/wirelessheadphones.webp',
    (SELECT id FROM public.categories WHERE slug = 'audio-headphones'),
    (SELECT id FROM public.brands WHERE slug = 'boat'),
    'https://amazon.in',
    true
),
(
    'Acer Nitro 5 Gaming Laptop',
    'acer-nitro-5-gaming-laptop',
    '12th Gen Intel i5 Gaming Laptop with RTX graphics',
    65000,
    '/Images/acernitro5.webp',
    (SELECT id FROM public.categories WHERE slug = 'laptops-computers'),
    (SELECT id FROM public.brands WHERE slug = 'acer'),
    'https://amazon.in',
    true
),
(
    'Lunar Vista Fitness Tracker',
    'lunar-vista-fitness-tracker',
    'Advanced fitness tracker with health monitoring and GPS',
    8000,
    '/Images/fitnesstracker.jpg',
    (SELECT id FROM public.categories WHERE slug = 'wearables'),
    (SELECT id FROM public.brands WHERE slug = 'lunar-vista'),
    'https://amazon.in',
    false
)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================
COMMENT ON TABLE public.profiles IS 'User profiles with additional information';
COMMENT ON TABLE public.categories IS 'Product categories for organizing products';
COMMENT ON TABLE public.brands IS 'Product brands and manufacturers';
COMMENT ON TABLE public.products IS 'Complete product catalog with comprehensive details';
COMMENT ON TABLE public.reviews IS 'User reviews and ratings for products';
COMMENT ON TABLE public.review_votes IS 'Track helpful/unhelpful votes on reviews';
COMMENT ON TABLE public.wishlists IS 'User wishlists for saving favorite products';
COMMENT ON TABLE public.product_views IS 'Analytics tracking for product views';

COMMENT ON COLUMN public.products.specifications IS 'JSON object for flexible product specifications (e.g., {"ram": "8GB", "storage": "256GB"})';
COMMENT ON COLUMN public.products.features IS 'Array of product features as text';
COMMENT ON COLUMN public.products.tags IS 'Array of searchable tags';
COMMENT ON COLUMN public.reviews.rating IS 'Rating from 1 to 5 stars';
COMMENT ON COLUMN public.reviews.is_verified_purchase IS 'Whether the reviewer purchased the product';

-- ============================================
-- USEFUL VIEWS (OPTIONAL)
-- ============================================

-- View for products with full details
CREATE OR REPLACE VIEW public.products_full AS
SELECT 
    p.*,
    c.name as category_name,
    c.slug as category_slug,
    b.name as brand_name,
    b.slug as brand_slug
FROM public.products p
LEFT JOIN public.categories c ON p.category_id = c.id
LEFT JOIN public.brands b ON p.brand_id = b.id;

-- View for reviews with user info
CREATE OR REPLACE VIEW public.reviews_with_user AS
SELECT 
    r.*,
    prof.full_name as user_name,
    prof.email as user_email,
    prof.avatar_url as user_avatar,
    p.name as product_name,
    p.slug as product_slug
FROM public.reviews r
LEFT JOIN public.profiles prof ON r.user_id = prof.id
LEFT JOIN public.products p ON r.product_id = p.id;

-- ============================================
-- SAMPLE API QUERIES
-- ============================================
/*
-- Get all active products with category and brand
SELECT * FROM products_full WHERE is_active = true ORDER BY created_at DESC;

-- Get products by category
SELECT * FROM products WHERE category_id = (SELECT id FROM categories WHERE slug = 'smartphones');

-- Get product with reviews
SELECT 
    p.*,
    json_agg(json_build_object(
        'id', r.id,
        'rating', r.rating,
        'review_text', r.review_text,
        'user_name', prof.full_name,
        'created_at', r.created_at
    )) as reviews
FROM products p
LEFT JOIN reviews r ON r.product_id = p.id AND r.is_approved = true
LEFT JOIN profiles prof ON r.user_id = prof.id
WHERE p.slug = 'apple-iphone-15-pro'
GROUP BY p.id;

-- Get featured products
SELECT * FROM products_full WHERE is_featured = true AND is_active = true;

-- Get trending products
SELECT * FROM products_full WHERE is_trending = true AND is_active = true;

-- Search products
SELECT * FROM products_full 
WHERE is_active = true 
AND (name ILIKE '%search_term%' OR description ILIKE '%search_term%')
ORDER BY average_rating DESC;

-- Get user's wishlist
SELECT p.*, w.created_at as added_to_wishlist_at
FROM wishlists w
JOIN products p ON w.product_id = p.id
WHERE w.user_id = 'user-uuid-here'
ORDER BY w.created_at DESC;
*/

-- ============================================
-- SCHEMA COMPLETE
-- ============================================
