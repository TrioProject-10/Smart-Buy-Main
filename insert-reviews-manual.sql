-- Smart Buy - Sample Reviews Data with Test Users
-- Run this script in Supabase SQL Editor

-- IMPORTANT: Update the product_id column to use text (product_name) instead of integer
-- Your frontend code uses product_id as text like 'boat-wireless-headphones'
-- So we need to match that

-- Step 1: Insert sample reviews (assuming you have registered users)
-- Replace the user_id with actual user IDs from your auth.users table
-- You can get user IDs by running: SELECT id, email FROM auth.users;

-- For testing purposes, here are the inserts with placeholder user_ids
-- YOU MUST REPLACE these UUIDs with actual user_ids from your auth.users table

-- Product 1: boAt Wireless Headphones
INSERT INTO public.reviews (user_id, product_id, product_name, rating, review_text, created_at, updated_at)
VALUES 
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'boat-wireless-headphones',
    'boAt Wireless Headphones',
    5,
    'Amazing sound quality! The bass is incredible and the battery life exceeds expectations. Comfortable to wear for long periods. Highly recommend for music lovers!',
    '2024-12-15 10:30:00+00'::timestamptz,
    '2024-12-15 10:30:00+00'::timestamptz
  ),
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'boat-wireless-headphones',
    'boAt Wireless Headphones',
    4,
    'Good headphones for the price. Sound quality is decent and they''re very comfortable. Only issue is the Bluetooth connection sometimes drops. Overall satisfied with purchase.',
    '2024-12-20 14:45:00+00'::timestamptz,
    '2024-12-20 14:45:00+00'::timestamptz
  ),
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'boat-wireless-headphones',
    'boAt Wireless Headphones',
    5,
    'Best wireless headphones I''ve owned! Crystal clear audio, excellent noise cancellation, and the design is sleek. Battery lasts all day. Worth every penny!',
    '2025-01-05 09:15:00+00'::timestamptz,
    '2025-01-05 09:15:00+00'::timestamptz
  );

-- Product 2: Acer Nitro 5 Gaming Laptop
INSERT INTO public.reviews (user_id, product_id, product_name, rating, review_text, created_at, updated_at)
VALUES 
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'acer-nitro-5-gaming-laptop',
    'Acer Nitro 5 Gaming Laptop',
    5,
    'Incredible gaming performance! Runs all modern games smoothly on high settings. The cooling system works great and the keyboard is responsive. Perfect for serious gamers.',
    '2024-12-10 16:20:00+00'::timestamptz,
    '2024-12-10 16:20:00+00'::timestamptz
  ),
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'acer-nitro-5-gaming-laptop',
    'Acer Nitro 5 Gaming Laptop',
    4,
    'Solid gaming laptop with good specs. Graphics are impressive and multitasking is smooth. Only downside is it gets a bit heavy to carry around. Great value for money though.',
    '2024-12-28 11:00:00+00'::timestamptz,
    '2024-12-28 11:00:00+00'::timestamptz
  ),
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'acer-nitro-5-gaming-laptop',
    'Acer Nitro 5 Gaming Laptop',
    5,
    'Exceeded all expectations! Fast processor, amazing display quality, and handles demanding games effortlessly. Build quality is premium. Highly recommended for gamers and professionals.',
    '2025-01-08 13:30:00+00'::timestamptz,
    '2025-01-08 13:30:00+00'::timestamptz
  );

-- Product 3: Lunar Vista Fitness Tracker
INSERT INTO public.reviews (user_id, product_id, product_name, rating, review_text, created_at, updated_at)
VALUES 
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'lunar-vista-fitness-tracker',
    'Lunar Vista Fitness Tracker',
    4,
    'Great fitness tracker for daily use. Accurate step counting and heart rate monitoring. Sleep tracking feature is helpful. Battery lasts about a week. Good purchase for fitness enthusiasts.',
    '2024-12-18 08:45:00+00'::timestamptz,
    '2024-12-18 08:45:00+00'::timestamptz
  ),
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'lunar-vista-fitness-tracker',
    'Lunar Vista Fitness Tracker',
    4,
    'Very accurate tracking and easy to use. Syncs well with my phone. The display is clear and bright. Only wish it had more sport modes. Overall, a reliable fitness companion.',
    '2025-01-02 15:20:00+00'::timestamptz,
    '2025-01-02 15:20:00+00'::timestamptz
  ),
  (
    '6ad46d83-ce85-4ab1-ab6c-d625b33e10d9'::uuid,
    'lunar-vista-fitness-tracker',
    'Lunar Vista Fitness Tracker',
    5,
    'Perfect for tracking my fitness goals! All features work flawlessly. Love the waterproof design - I can wear it while swimming. Notifications are timely and battery life is excellent!',
    '2025-01-12 10:00:00+00'::timestamptz,
    '2025-01-12 10:00:00+00'::timestamptz
  );

-- Query to verify the inserts
SELECT 
  product_id,
  product_name,
  COUNT(*) as review_count,
  ROUND(AVG(rating)::numeric, 1) as avg_rating
FROM public.reviews
GROUP BY product_id, product_name
ORDER BY product_name;

-- HOW TO USE THIS FILE:
-- 1. First, create users in your app by signing up at /auth/signup.html
-- 2. Get the user IDs by running: SELECT id, email FROM auth.users;
-- 3. Replace 'YOUR_USER_ID_1', 'YOUR_USER_ID_2', 'YOUR_USER_ID_3' with actual user IDs
-- 4. Run this script in Supabase SQL Editor
-- 5. Refresh your homepage to see the reviews!
