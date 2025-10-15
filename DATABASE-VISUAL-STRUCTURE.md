# 📊 Smart Buy Database Schema - Visual Structure

## 🗂️ Database Relationships

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SMART BUY DATABASE                            │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│   auth.users     │ (Supabase Auth)
│  ──────────────  │
│  • id (UUID)     │
│  • email         │
│  • password      │
└────────┬─────────┘
         │
         │ 1:1
         ▼
┌──────────────────┐
│    profiles      │
│  ──────────────  │
│  • id (UUID) PK  │──────────────────────┐
│  • full_name     │                      │
│  • email         │                      │
│  • avatar_url    │                      │
│  • phone         │                      │
│  • bio           │                      │
└──────────────────┘                      │
                                          │
                                          │ 1:Many
         ┌────────────────────────────────┼────────────────────────┐
         │                                │                        │
         ▼                                ▼                        ▼
┌──────────────────┐            ┌──────────────────┐    ┌──────────────────┐
│     reviews      │            │   wishlists      │    │  review_votes    │
│  ──────────────  │            │  ──────────────  │    │  ──────────────  │
│  • id (UUID) PK  │            │  • id (UUID) PK  │    │  • id (UUID) PK  │
│  • user_id FK    │            │  • user_id FK    │    │  • user_id FK    │
│  • product_id FK │            │  • product_id FK │    │  • review_id FK  │
│  • rating (1-5)  │            │  • notes         │    │  • is_helpful    │
│  • review_text   │            └──────────────────┘    └──────────────────┘
│  • title         │                     │                        │
│  • pros[]        │                     │                        │
│  • cons[]        │                     │                        │
│  • helpful_count │◄────────────────────┘                        │
│  • is_approved   │◄─────────────────────────────────────────────┘
└────────┬─────────┘
         │
         │ Many:1
         │
         ▼
┌──────────────────┐
│    products      │ ◄────────────────────┐
│  ──────────────  │                      │
│  • id (SERIAL)PK │                      │
│  • name          │                      │
│  • slug (unique) │                      │
│  • description   │                      │ Many:1
│  • price         │                      │
│  • original_price│                      │
│  • image_url     │                      │
│  • image_urls[]  │          ┌──────────────────┐
│  • category_id FK│─────────►│   categories     │
│  • brand_id FK   │          │  ──────────────  │
│  • model_number  │          │  • id (SERIAL)PK │
│  • sku           │          │  • name          │
│  • specifications│          │  • slug (unique) │
│  • features[]    │          │  • description   │
│  • tags[]        │          │  • icon_url      │
│  • stock_qty     │          │  • parent_cat_id │
│  • is_in_stock   │          │  • display_order │
│  • amazon_url    │          │  • is_active     │
│  • flipkart_url  │          └──────────────────┘
│  • official_url  │
│  • avg_rating    │◄───── Auto-calculated
│  • total_reviews │◄───── Auto-calculated
│  • is_active     │
│  • is_featured   │          ┌──────────────────┐
│  • is_trending   │          │     brands       │
│  • meta_title    │          │  ──────────────  │
└────────┬─────────┘          │  • id (SERIAL)PK │
         │                    │  • name          │
         │ Many:1             │  • slug (unique) │
         └───────────────────►│  • logo_url      │
                              │  • website_url   │
         ┌────────────────────│  • description   │
         │                    │  • is_active     │
         │ 1:Many             └──────────────────┘
         ▼
┌──────────────────┐
│  product_views   │
│  ──────────────  │
│  • id (UUID) PK  │
│  • product_id FK │
│  • user_id FK    │
│  • ip_address    │
│  • user_agent    │
│  • viewed_at     │
└──────────────────┘
```

## 🔄 Data Flow Diagram

```
┌──────────────┐
│    USER      │
└──────┬───────┘
       │
       │ (1) Signs Up
       ▼
┌──────────────────┐     ┌──────────────────┐
│  auth.users      │────►│   profiles       │
│  (Supabase Auth) │     │  (Auto Created)  │
└──────────────────┘     └──────────────────┘
       │
       │ (2) Browse Products
       ▼
┌──────────────────────────────────────┐
│            products                  │
│  ┌────────────────────────────────┐ │
│  │ Category: Smartphones          │ │
│  │ Brand: Apple                   │ │
│  │ Price: ₹1,35,000              │ │
│  │ Rating: 4.8 ⭐ (104 reviews)   │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘
       │
       │ (3) View Product
       ▼
┌──────────────────┐
│  product_views   │ (Analytics)
└──────────────────┘
       │
       │ (4) Add to Wishlist
       ▼
┌──────────────────┐
│   wishlists      │
└──────────────────┘
       │
       │ (5) Write Review
       ▼
┌──────────────────┐     ┌─────────────────────┐
│     reviews      │────►│   products          │
│  Rating: 5⭐     │     │  avg_rating ⬆       │
│  Review Text     │     │  total_reviews ⬆    │
└──────────────────┘     └─────────────────────┘
       │                        ▲
       │ (6) Others Vote        │
       ▼                        │
┌──────────────────┐            │
│  review_votes    │────────────┘
│  Helpful: Yes/No │  (Updates helpful_count)
└──────────────────┘
```

## 📋 Table Summary

| Table | Records | Purpose |
|-------|---------|---------|
| **profiles** | Dynamic | User account information |
| **categories** | 10 | Product categories (Electronics, Fashion, etc.) |
| **brands** | 23 | Product brands (Apple, Samsung, Nike, etc.) |
| **products** | 30+ | Main product catalog |
| **reviews** | Dynamic | User reviews and ratings |
| **review_votes** | Dynamic | Helpful/unhelpful votes on reviews |
| **wishlists** | Dynamic | User saved/favorite products |
| **product_views** | Dynamic | Product view analytics |

## 🔐 Security (Row Level Security)

```
┌─────────────────────────────────────────────────┐
│              RLS POLICIES                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  📖 VIEWING (SELECT)                           │
│  ✓ Products   → Everyone (if is_active=true)  │
│  ✓ Categories → Everyone (if is_active=true)  │
│  ✓ Brands     → Everyone (if is_active=true)  │
│  ✓ Reviews    → Everyone (if is_approved=true)│
│  ✓ Profiles   → Everyone                       │
│  ✓ Wishlists  → Only owner                    │
│                                                 │
│  ✏️ WRITING (INSERT/UPDATE/DELETE)            │
│  ✓ Reviews    → Authenticated users only       │
│  ✓ Own reviews → User can edit/delete own     │
│  ✓ Wishlists  → User can manage own           │
│  ✓ Votes      → Authenticated users only       │
│                                                 │
└─────────────────────────────────────────────────┘
```

## ⚙️ Automatic Triggers

```
┌──────────────────────────────────────────────────┐
│             AUTOMATED PROCESSES                  │
├──────────────────────────────────────────────────┤
│                                                  │
│  1️⃣ USER SIGNUP                                 │
│     auth.users (new) ──► profiles (auto-create) │
│                                                  │
│  2️⃣ REVIEW ADDED/UPDATED/DELETED               │
│     reviews ──► products.average_rating ⬆⬇     │
│              ──► products.total_reviews ⬆⬇     │
│                                                  │
│  3️⃣ REVIEW VOTED                               │
│     review_votes ──► reviews.helpful_count ⬆⬇  │
│                   ──► reviews.unhelpful_count ⬆⬇│
│                                                  │
│  4️⃣ RECORD UPDATED                             │
│     Any table ──► updated_at = NOW()            │
│                                                  │
└──────────────────────────────────────────────────┘
```

## 📊 Product Data Structure

```
PRODUCT
├── Basic Info
│   ├── name
│   ├── slug (URL-friendly)
│   ├── description
│   └── short_description
│
├── Pricing
│   ├── price (current)
│   ├── original_price
│   ├── discount_percentage
│   └── currency (INR)
│
├── Media
│   ├── image_url (primary)
│   └── image_urls[] (gallery)
│
├── Classification
│   ├── category_id ──► categories
│   └── brand_id ──► brands
│
├── Details
│   ├── model_number
│   ├── sku
│   ├── specifications (JSONB) ─┐
│   ├── features[] (Array)      │ Flexible
│   └── tags[] (Array)          │ Structure
│                                ┘
├── Inventory
│   ├── stock_quantity
│   └── is_in_stock
│
├── External Links
│   ├── amazon_url
│   ├── flipkart_url
│   └── official_url
│
├── Social Proof (Auto-calculated)
│   ├── average_rating ⭐
│   └── total_reviews 💬
│
├── Status Flags
│   ├── is_active (visible?)
│   ├── is_featured (homepage?)
│   └── is_trending (trending?)
│
└── SEO
    ├── meta_title
    ├── meta_description
    └── meta_keywords[]
```

## 🔍 Query Patterns

### Pattern 1: Get Products by Category
```sql
products (category_id = X)
    ↓
categories (slug = 'smartphones')
    ↓
Result: All smartphones
```

### Pattern 2: Get Product with Reviews
```sql
products (id = X)
    ↓
reviews (product_id = X)
    ↓
profiles (user_id = reviews.user_id)
    ↓
Result: Product with user reviews
```

### Pattern 3: User Wishlist
```sql
wishlists (user_id = X)
    ↓
products (id = wishlists.product_id)
    ↓
Result: User's saved products
```

## 📈 Performance Indexes

```
INDEXED FIELDS (Fast Queries)
├── products
│   ├── category_id
│   ├── brand_id
│   ├── slug ⚡
│   ├── is_active
│   ├── is_featured
│   ├── average_rating
│   └── price
├── reviews
│   ├── user_id
│   ├── product_id
│   ├── rating
│   └── created_at
├── categories
│   ├── slug ⚡
│   └── is_active
└── brands
    ├── slug ⚡
    └── is_active
```

## 🎯 Common Use Cases

### Use Case 1: Homepage Featured Products
```
Query: products WHERE is_featured = true AND is_active = true
Order: average_rating DESC
Limit: 6
```

### Use Case 2: Category Page
```
Query: products WHERE category_id = X AND is_active = true
Order: average_rating DESC, total_reviews DESC
```

### Use Case 3: Product Detail Page
```
Query 1: products WHERE slug = 'product-slug'
Query 2: reviews WHERE product_id = X AND is_approved = true
Join: profiles for user info
```

### Use Case 4: User Dashboard
```
Query 1: wishlists WHERE user_id = X
Query 2: reviews WHERE user_id = X
Join: products for details
```

## 💾 Storage Estimates

```
Approximate Storage per Record:
├── Product: ~2-5 KB (with specs & images)
├── Review: ~1-2 KB
├── Profile: ~500 bytes
├── Wishlist: ~100 bytes
├── Product View: ~200 bytes
└── Review Vote: ~100 bytes

For 10,000 products + 50,000 reviews:
≈ 20-50 MB (very manageable!)
```

---

## 📚 Legend

- **PK** = Primary Key
- **FK** = Foreign Key
- **⬆** = Auto-increments
- **⬇** = Auto-decrements
- **⚡** = Indexed for fast queries
- **[]** = Array field
- **JSONB** = Flexible JSON field

---

This visual structure helps you understand how all the tables connect and work together! 🎨
