# Quick Reference: Adding Products to Smart Buy Database

## 🚀 Quick Add Product Template

### Copy & Paste SQL Template

```sql
INSERT INTO public.products (
    name,                    -- Required: Product name
    slug,                    -- Required: URL-friendly name (lowercase-with-dashes)
    description,             -- Product description
    short_description,       -- Brief description
    price,                   -- Required: Price in rupees
    original_price,          -- Original price (if discounted)
    discount_percentage,     -- Discount % (calculated automatically)
    image_url,              -- Required: Main product image path
    image_urls,             -- Array of additional images: ARRAY['/path1.jpg', '/path2.jpg']
    category_id,            -- Get from: SELECT id FROM categories WHERE slug = 'category-slug'
    brand_id,               -- Get from: SELECT id FROM brands WHERE slug = 'brand-slug'
    model_number,           -- Model/SKU
    specifications,         -- JSON: '{"key": "value", "key2": "value2"}'
    features,               -- Array: ARRAY['Feature 1', 'Feature 2', 'Feature 3']
    tags,                   -- Array: ARRAY['tag1', 'tag2', 'tag3']
    stock_quantity,         -- Number in stock
    is_in_stock,           -- true/false
    amazon_url,            -- Amazon product link
    flipkart_url,          -- Flipkart product link
    official_url,          -- Official website link
    is_featured,           -- true/false (show on homepage)
    is_trending,           -- true/false (show in trending)
    is_active              -- true/false (visible to users)
) VALUES (
    'Your Product Name',
    'your-product-name',
    'Detailed product description goes here',
    'Short description',
    49999,
    59999,
    17,
    '/Images/category/product-image.jpg',
    ARRAY['/Images/category/product-1.jpg', '/Images/category/product-2.jpg'],
    (SELECT id FROM categories WHERE slug = 'smartphones'),
    (SELECT id FROM brands WHERE slug = 'apple'),
    'MODEL-123',
    '{"ram": "8GB", "storage": "256GB"}',
    ARRAY['Feature 1', 'Feature 2', 'Feature 3'],
    ARRAY['smartphone', '5g', 'flagship'],
    100,
    true,
    'https://amazon.in/product-link',
    'https://flipkart.com/product-link',
    'https://brand.com/product',
    false,
    false,
    true
);
```

## 📋 Category Slugs Reference

```sql
-- Available Categories (use in category_id)
'electronics'           -- General Electronics
'smartphones'          -- Mobile Phones
'laptops-computers'    -- Laptops & PCs
'home-appliances'      -- Home Appliances
'fashion-lifestyle'    -- Fashion Items
'footwear'            -- Shoes & Footwear
'sports-fitness'      -- Sports Equipment
'kitchen-appliances'  -- Kitchen Items
'audio-headphones'    -- Audio Equipment
'wearables'           -- Smartwatches & Trackers
```

## 🏷️ Brand Slugs Reference

```sql
-- Available Brands (use in brand_id)
'apple', 'samsung', 'oneplus', 'google', 'realme', 'xiaomi', 'redmi',
'nothing', 'vivo', 'adidas', 'nike', 'puma', 'reebok', 'skechers',
'dyson', 'lg', 'philips', 'bajaj', 'prestige', 'ifb', 'boat', 'acer',
'lunar-vista'
```

## 🎯 Real Examples

### Example 1: Smartphone

```sql
INSERT INTO public.products (
    name, slug, description, price, image_url, 
    category_id, brand_id, specifications, features, 
    amazon_url, is_featured, is_active
) VALUES (
    'iPhone 16 Pro Max',
    'iphone-16-pro-max',
    'Latest iPhone with advanced AI features and titanium design',
    159999,
    '/Images/smartphones/iphone-16-pro-max.jpg',
    (SELECT id FROM categories WHERE slug = 'smartphones'),
    (SELECT id FROM brands WHERE slug = 'apple'),
    '{"display": "6.9 inch", "processor": "A18 Pro", "ram": "8GB", "storage": "256GB", "camera": "48MP Triple"}',
    ARRAY['A18 Pro chip', 'ProMotion display', 'Action Button', '5x optical zoom'],
    'https://amazon.in/iphone-16-pro-max',
    true,
    true
);
```

### Example 2: Shoes

```sql
INSERT INTO public.products (
    name, slug, description, price, image_url,
    category_id, brand_id, specifications, features,
    amazon_url, is_active
) VALUES (
    'Nike Air Max 270',
    'nike-air-max-270',
    'Iconic sneakers with visible Air Max cushioning',
    12995,
    '/Images/shoes/nike-air-max-270.jpg',
    (SELECT id FROM categories WHERE slug = 'footwear'),
    (SELECT id FROM brands WHERE slug = 'nike'),
    '{"type": "Running Shoes", "material": "Mesh & Synthetic", "sizes": "7-11 UK"}',
    ARRAY['Max Air unit', 'Breathable mesh', 'Durable rubber outsole'],
    'https://amazon.in/nike-air-max-270',
    true
);
```

### Example 3: Home Appliance

```sql
INSERT INTO public.products (
    name, slug, description, price, image_url,
    category_id, brand_id, specifications, features,
    amazon_url, is_active
) VALUES (
    'Samsung 7kg Washing Machine',
    'samsung-7kg-washing-machine',
    'Fully automatic front load washer with AI control',
    32990,
    '/Images/homeappliances/samsung-washer-7kg.jpg',
    (SELECT id FROM categories WHERE slug = 'home-appliances'),
    (SELECT id FROM brands WHERE slug = 'samsung'),
    '{"capacity": "7kg", "type": "Front Load", "energy_rating": "5 Star", "rpm": "1200"}',
    ARRAY['AI Control', 'Steam wash', 'Child lock', 'Delay start'],
    'https://amazon.in/samsung-washer',
    true
);
```

## 🔍 Check Existing Data

### View All Categories
```sql
SELECT id, name, slug FROM categories WHERE is_active = true;
```

### View All Brands
```sql
SELECT id, name, slug FROM brands WHERE is_active = true;
```

### View Products by Category
```sql
SELECT name, price, slug 
FROM products 
WHERE category_id = (SELECT id FROM categories WHERE slug = 'smartphones')
ORDER BY created_at DESC;
```

## ✅ Add New Category (If Needed)

```sql
INSERT INTO categories (name, slug, description, display_order, is_active) 
VALUES ('New Category', 'new-category', 'Description here', 11, true);
```

## ✅ Add New Brand (If Needed)

```sql
INSERT INTO brands (name, slug, website_url, is_active) 
VALUES ('Brand Name', 'brand-name', 'https://brand.com', true);
```

## 🎨 Specifications Format by Category

### Smartphones
```json
{
  "display": "6.7 inch AMOLED",
  "processor": "Snapdragon 8 Gen 3",
  "ram": "12GB",
  "storage": "256GB",
  "camera_main": "200MP",
  "battery": "5000mAh",
  "os": "Android 14"
}
```

### Footwear
```json
{
  "type": "Running Shoes",
  "material": "Mesh and Synthetic",
  "sizes": "7-11 UK",
  "weight": "280g",
  "color": "Black/White"
}
```

### Appliances
```json
{
  "capacity": "7kg",
  "type": "Front Load",
  "energy_rating": "5 Star",
  "warranty": "2 years",
  "dimensions": "60x60x85 cm"
}
```

## 🚨 Common Mistakes to Avoid

❌ **Don't** use duplicate slugs (must be unique)
✅ **Do** use lowercase-with-dashes format: `product-name-here`

❌ **Don't** forget required fields: name, slug, price, image_url
✅ **Do** fill all required fields

❌ **Don't** use invalid category/brand IDs
✅ **Do** use subquery: `(SELECT id FROM categories WHERE slug = 'category-slug')`

❌ **Don't** set negative prices
✅ **Do** use positive decimal values

## 📱 Using JavaScript (Supabase Client)

```javascript
const { data, error } = await supabase
  .from('products')
  .insert([
    {
      name: 'Product Name',
      slug: 'product-name',
      description: 'Description here',
      price: 49999,
      image_url: '/Images/product.jpg',
      category_id: 2,
      brand_id: 5,
      is_active: true
    }
  ])
  .select()

console.log(data, error)
```

## 🔄 Update Existing Product

```sql
UPDATE products 
SET 
    price = 45999,
    is_featured = true,
    specifications = '{"ram": "12GB", "storage": "512GB"}'
WHERE slug = 'product-slug';
```

## 🗑️ Delete Product (Soft Delete)

```sql
-- Don't actually delete, just deactivate
UPDATE products SET is_active = false WHERE slug = 'product-slug';
```

## 📊 Verify Your Addition

```sql
-- Check if product was added
SELECT * FROM products WHERE slug = 'your-product-slug';

-- View with category and brand names
SELECT 
    p.name,
    p.price,
    c.name as category,
    b.name as brand
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN brands b ON p.brand_id = b.id
WHERE p.slug = 'your-product-slug';
```

---

💡 **Tip**: Always test with a single product first before bulk importing!
