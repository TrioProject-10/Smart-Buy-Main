# Smart Buy - Comprehensive Supabase Schema Guide

## 📋 Overview

This document explains the enhanced Supabase schema for the Smart Buy product review platform. The schema supports:
- Multiple product categories (Smartphones, Footwear, Home Appliances, Electronics)
- Comprehensive product information with images, pricing, and specifications
- User reviews and ratings with helpfulness voting
- Wishlists and product tracking
- Analytics and product views

## 🗄️ Database Structure

### Core Tables

#### 1. **profiles**
Stores user profile information linked to Supabase Auth
```sql
- id (UUID) - Links to auth.users
- full_name (TEXT)
- email (TEXT) - Unique
- avatar_url (TEXT)
- phone (TEXT)
- bio (TEXT)
- created_at, updated_at (TIMESTAMP)
```

#### 2. **categories**
Organizes products into hierarchical categories
```sql
- id (SERIAL)
- name (TEXT) - e.g., "Electronics", "Smartphones"
- slug (TEXT) - URL-friendly version
- description (TEXT)
- icon_url (TEXT)
- parent_category_id (INTEGER) - For sub-categories
- display_order (INTEGER)
- is_active (BOOLEAN)
```

#### 3. **brands**
Stores product brands/manufacturers
```sql
- id (SERIAL)
- name (TEXT) - e.g., "Apple", "Samsung"
- slug (TEXT)
- logo_url (TEXT)
- website_url (TEXT)
- description (TEXT)
- is_active (BOOLEAN)
```

#### 4. **products** ⭐ MAIN TABLE
Comprehensive product catalog
```sql
- id (SERIAL)
- name (TEXT)
- slug (TEXT) - Unique URL-friendly identifier
- description (TEXT)
- short_description (TEXT)

PRICING:
- price (DECIMAL) - Current price
- original_price (DECIMAL) - Original price before discount
- discount_percentage (INTEGER)
- currency (TEXT) - Default 'INR'

IMAGES:
- image_url (TEXT) - Primary product image
- image_urls (TEXT[]) - Array of additional images

CATEGORIZATION:
- category_id (INTEGER) - Links to categories
- brand_id (INTEGER) - Links to brands

DETAILS:
- model_number (TEXT)
- sku (TEXT) - Stock Keeping Unit
- specifications (JSONB) - Flexible JSON for specs
- features (TEXT[]) - Array of features
- tags (TEXT[]) - Searchable tags

INVENTORY:
- stock_quantity (INTEGER)
- is_in_stock (BOOLEAN)

EXTERNAL LINKS:
- amazon_url (TEXT)
- flipkart_url (TEXT)
- official_url (TEXT)

RATINGS:
- average_rating (DECIMAL) - Auto-calculated
- total_reviews (INTEGER) - Auto-calculated

STATUS:
- is_active (BOOLEAN)
- is_featured (BOOLEAN)
- is_trending (BOOLEAN)

SEO:
- meta_title (TEXT)
- meta_description (TEXT)
- meta_keywords (TEXT[])
```

#### 5. **reviews**
User reviews and ratings
```sql
- id (UUID)
- user_id (UUID)
- product_id (INTEGER)
- rating (INTEGER) - 1 to 5 stars
- title (TEXT)
- review_text (TEXT)
- pros (TEXT[])
- cons (TEXT[])
- is_verified_purchase (BOOLEAN)
- helpful_count (INTEGER) - Auto-calculated
- unhelpful_count (INTEGER) - Auto-calculated
- review_images (TEXT[])
- is_approved (BOOLEAN)
- is_featured (BOOLEAN)
```

#### 6. **review_votes**
Track helpful/unhelpful votes on reviews
```sql
- id (UUID)
- review_id (UUID)
- user_id (UUID)
- is_helpful (BOOLEAN) - true=helpful, false=unhelpful
```

#### 7. **wishlists**
User favorite products
```sql
- id (UUID)
- user_id (UUID)
- product_id (INTEGER)
- notes (TEXT)
```

#### 8. **product_views**
Analytics for tracking product views
```sql
- id (UUID)
- product_id (INTEGER)
- user_id (UUID) - Optional
- ip_address (INET)
- user_agent (TEXT)
- viewed_at (TIMESTAMP)
```

## 🚀 How to Add New Products

### Method 1: Using SQL (Direct Insert)

```sql
INSERT INTO public.products (
    name, 
    slug, 
    description, 
    price, 
    image_url, 
    category_id, 
    brand_id,
    amazon_url,
    is_featured,
    specifications,
    features
) VALUES (
    'Product Name',
    'product-slug',
    'Detailed product description',
    49999,
    '/Images/products/product-image.jpg',
    (SELECT id FROM categories WHERE slug = 'smartphones'),
    (SELECT id FROM brands WHERE slug = 'apple'),
    'https://amazon.in/product-link',
    false,
    '{"ram": "8GB", "storage": "256GB", "processor": "A17 Pro"}',
    ARRAY['Feature 1', 'Feature 2', 'Feature 3']
);
```

### Method 2: Using Supabase JavaScript Client

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

// Add a new product
async function addProduct() {
  const { data, error } = await supabase
    .from('products')
    .insert([
      {
        name: 'Samsung Galaxy S24 Ultra',
        slug: 'samsung-galaxy-s24-ultra',
        description: 'Latest flagship smartphone with AI features',
        short_description: 'Premium Android flagship',
        price: 129999,
        original_price: 149999,
        discount_percentage: 13,
        image_url: '/Images/smartphones/galaxy-s24-ultra.jpg',
        category_id: 2, // or use a query to get category by slug
        brand_id: 2,    // or use a query to get brand by slug
        amazon_url: 'https://amazon.in/samsung-s24',
        specifications: {
          ram: '12GB',
          storage: '512GB',
          display: '6.8 inch AMOLED',
          processor: 'Snapdragon 8 Gen 3',
          camera: '200MP Main'
        },
        features: [
          'S Pen included',
          '5000mAh battery',
          '45W fast charging',
          'IP68 water resistant'
        ],
        tags: ['flagship', 'android', '5g', 'camera-phone'],
        is_active: true,
        is_featured: true,
        is_in_stock: true,
        stock_quantity: 50
      }
    ])
    .select()

  if (error) console.error('Error:', error)
  else console.log('Product added:', data)
}
```

### Method 3: Bulk Insert (Multiple Products)

```sql
INSERT INTO public.products (name, slug, description, price, image_url, category_id, brand_id) VALUES
('Product 1', 'product-1', 'Description 1', 10000, '/Images/product1.jpg', 1, 1),
('Product 2', 'product-2', 'Description 2', 20000, '/Images/product2.jpg', 1, 2),
('Product 3', 'product-3', 'Description 3', 30000, '/Images/product3.jpg', 2, 3)
ON CONFLICT (slug) DO NOTHING;
```

## 📝 Common Queries

### Get All Products with Category and Brand

```sql
SELECT 
    p.*,
    c.name as category_name,
    b.name as brand_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN brands b ON p.brand_id = b.id
WHERE p.is_active = true
ORDER BY p.created_at DESC;
```

### Get Products by Category

```sql
-- Using category slug
SELECT * FROM products 
WHERE category_id = (SELECT id FROM categories WHERE slug = 'smartphones')
AND is_active = true;
```

### Get Single Product with Reviews

```sql
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
```

### Search Products

```sql
SELECT * FROM products 
WHERE is_active = true 
AND (
    name ILIKE '%search_term%' 
    OR description ILIKE '%search_term%'
    OR 'search_term' = ANY(tags)
)
ORDER BY average_rating DESC, total_reviews DESC;
```

### Get Featured/Trending Products

```sql
-- Featured products
SELECT * FROM products 
WHERE is_featured = true AND is_active = true 
ORDER BY average_rating DESC 
LIMIT 10;

-- Trending products
SELECT * FROM products 
WHERE is_trending = true AND is_active = true 
ORDER BY created_at DESC 
LIMIT 10;
```

## 🔧 API Examples with Supabase Client

### Fetch Products

```javascript
// Get all products
const { data: products } = await supabase
  .from('products')
  .select('*, categories(name), brands(name)')
  .eq('is_active', true)

// Get products by category
const { data: smartphones } = await supabase
  .from('products')
  .select('*')
  .eq('category_id', 2)
  .eq('is_active', true)

// Get single product with reviews
const { data: product } = await supabase
  .from('products')
  .select(`
    *,
    categories(name, slug),
    brands(name, slug),
    reviews(
      id,
      rating,
      review_text,
      created_at,
      profiles(full_name, avatar_url)
    )
  `)
  .eq('slug', 'apple-iphone-15-pro')
  .single()

// Search products
const { data: results } = await supabase
  .from('products')
  .select('*')
  .or(`name.ilike.%${searchTerm}%,description.ilike.%${searchTerm}%`)
  .eq('is_active', true)
```

### Submit a Review

```javascript
async function submitReview(productId, rating, reviewText) {
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    throw new Error('User must be logged in')
  }

  const { data, error } = await supabase
    .from('reviews')
    .insert([
      {
        user_id: user.id,
        product_id: productId,
        rating: rating,
        review_text: reviewText,
        is_approved: true
      }
    ])
    .select()

  return { data, error }
}
```

### Add to Wishlist

```javascript
async function addToWishlist(productId) {
  const { data: { user } } = await supabase.auth.getUser()
  
  const { data, error } = await supabase
    .from('wishlists')
    .insert([
      {
        user_id: user.id,
        product_id: productId
      }
    ])
    .select()

  return { data, error }
}
```

### Track Product View

```javascript
async function trackProductView(productId) {
  const { data: { user } } = await supabase.auth.getUser()
  
  const { error } = await supabase
    .from('product_views')
    .insert([
      {
        product_id: productId,
        user_id: user?.id || null,
        viewed_at: new Date().toISOString()
      }
    ])
}
```

## 🎯 Product Specifications (JSONB Format)

The `specifications` field is flexible JSONB. Examples for different categories:

### Smartphones
```json
{
  "display": "6.7 inch AMOLED",
  "processor": "Snapdragon 8 Gen 3",
  "ram": "12GB",
  "storage": "256GB",
  "camera_main": "200MP",
  "camera_front": "32MP",
  "battery": "5000mAh",
  "os": "Android 14",
  "5g": true
}
```

### Footwear
```json
{
  "type": "Running Shoes",
  "material": "Mesh and Synthetic",
  "sole_material": "Rubber",
  "closure_type": "Lace-up",
  "color": "Black/White",
  "sizes_available": ["7", "8", "9", "10", "11"],
  "weight": "280g",
  "water_resistant": false
}
```

### Home Appliances
```json
{
  "capacity": "265L",
  "energy_rating": "5 Star",
  "technology": "Inverter Compressor",
  "annual_power_consumption": "150 kWh",
  "warranty": "10 years on compressor",
  "dimensions": "60 x 65 x 170 cm",
  "color": "Silver"
}
```

## 🔐 Security Features

### Row Level Security (RLS)
- Products, categories, and brands are viewable by everyone
- Only authenticated users can submit reviews
- Users can only edit/delete their own reviews
- Wishlists are private to each user

### Automatic Updates
- Product ratings automatically update when reviews are added/edited
- Review helpfulness counts update when votes are cast
- Timestamps automatically update on record changes

## 📊 Analytics Queries

### Most Viewed Products (Last 30 Days)
```sql
SELECT 
    p.name,
    p.slug,
    COUNT(pv.id) as view_count
FROM products p
JOIN product_views pv ON pv.product_id = p.id
WHERE pv.viewed_at > NOW() - INTERVAL '30 days'
GROUP BY p.id
ORDER BY view_count DESC
LIMIT 10;
```

### Top Rated Products
```sql
SELECT 
    name,
    average_rating,
    total_reviews,
    price
FROM products
WHERE total_reviews >= 10
ORDER BY average_rating DESC, total_reviews DESC
LIMIT 20;
```

### Most Reviewed Products
```sql
SELECT 
    p.name,
    p.average_rating,
    p.total_reviews,
    c.name as category
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
ORDER BY p.total_reviews DESC
LIMIT 10;
```

## 🛠️ Maintenance Tasks

### Update Product Status
```sql
-- Mark product as featured
UPDATE products 
SET is_featured = true 
WHERE slug = 'apple-iphone-15-pro';

-- Mark product as out of stock
UPDATE products 
SET is_in_stock = false, stock_quantity = 0 
WHERE id = 123;
```

### Bulk Update Prices
```sql
-- Apply 10% discount to all Samsung products
UPDATE products p
SET 
    original_price = price,
    price = price * 0.9,
    discount_percentage = 10
WHERE brand_id = (SELECT id FROM brands WHERE slug = 'samsung');
```

### Clean Old Product Views (Keep last 90 days)
```sql
DELETE FROM product_views
WHERE viewed_at < NOW() - INTERVAL '90 days';
```

## 📦 Existing Sample Data

The schema includes pre-populated data:
- **10 Categories**: Electronics, Smartphones, Footwear, Home Appliances, etc.
- **23 Brands**: Apple, Samsung, Nike, Adidas, Sony, etc.
- **30+ Products**: Smartphones, shoes, home appliances, electronics

All sample products from your HTML files are included!

## 🚦 Getting Started

1. **Run the Schema**: Execute `supabase-schema-enhanced.sql` in your Supabase SQL editor
2. **Configure Auth**: Set up Supabase authentication
3. **Add Products**: Use the methods above to add more products
4. **Test Reviews**: Have users submit reviews to test the auto-rating system
5. **Monitor**: Use analytics queries to track product performance

## 💡 Tips

- Always use unique `slug` values for products (URL-friendly)
- Set `is_featured` for homepage products
- Use `specifications` JSONB for flexible product attributes
- Add multiple images using the `image_urls` array
- Tag products properly for better search results

---

For questions or issues, refer to the Supabase documentation or the Smart Buy development team.
