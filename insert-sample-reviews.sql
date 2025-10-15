-- Sample Reviews Data for Smart Buy
-- This script inserts sample reviews for 3 products with 3 reviews each

-- First, you need to create test users in Supabase Auth or use existing user IDs
-- Replace the user_id values below with actual user IDs from your auth.users table

-- Product 1: boAt Wireless Headphones (product_id = 1)
INSERT INTO public.reviews (id, user_id, product_id, product_name, rating, review_text, created_at, updated_at)
VALUES 
  (
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    '550e8400-e29b-41d4-a716-446655440100'::uuid, -- Replace with actual user_id
    1,
    'boat-wireless-headphones',
    5,
    'Amazing sound quality! The bass is incredible and the battery life exceeds expectations. Comfortable to wear for long periods. Highly recommend for music lovers!',
    '2024-12-15 10:30:00+00'::timestamptz,
    '2024-12-15 10:30:00+00'::timestamptz
  ),
  (
    '550e8400-e29b-41d4-a716-446655440002'::uuid,
    '550e8400-e29b-41d4-a716-446655440101'::uuid, -- Replace with actual user_id
    1,
    'boat-wireless-headphones',
    4,
    'Good headphones for the price. Sound quality is decent and they''re very comfortable. Only issue is the Bluetooth connection sometimes drops. Overall satisfied with purchase.',
    '2024-12-20 14:45:00+00'::timestamptz,
    '2024-12-20 14:45:00+00'::timestamptz
  ),
  (
    '550e8400-e29b-41d4-a716-446655440003'::uuid,
    '550e8400-e29b-41d4-a716-446655440102'::uuid, -- Replace with actual user_id
    1,
    'boat-wireless-headphones',
    5,
    'Best wireless headphones I''ve owned! Crystal clear audio, excellent noise cancellation, and the design is sleek. Battery lasts all day. Worth every penny!',
    '2025-01-05 09:15:00+00'::timestamptz,
    '2025-01-05 09:15:00+00'::timestamptz
  );

-- Product 2: Acer Nitro 5 Gaming Laptop (product_id = 2)
INSERT INTO public.reviews (id, user_id, product_id, product_name, rating, review_text, created_at, updated_at)
VALUES 
  (
    '550e8400-e29b-41d4-a716-446655440004'::uuid,
    '550e8400-e29b-41d4-a716-446655440103'::uuid, -- Replace with actual user_id
    2,
    'acer-nitro-5-gaming-laptop',
    5,
    'Incredible gaming performance! Runs all modern games smoothly on high settings. The cooling system works great and the keyboard is responsive. Perfect for serious gamers.',
    '2024-12-10 16:20:00+00'::timestamptz,
    '2024-12-10 16:20:00+00'::timestamptz
  ),
  (
    '550e8400-e29b-41d4-a716-446655440005'::uuid,
    '550e8400-e29b-41d4-a716-446655440104'::uuid, -- Replace with actual user_id
    2,
    'acer-nitro-5-gaming-laptop',
    4,
    'Solid gaming laptop with good specs. Graphics are impressive and multitasking is smooth. Only downside is it gets a bit heavy to carry around. Great value for money though.',
    '2024-12-28 11:00:00+00'::timestamptz,
    '2024-12-28 11:00:00+00'::timestamptz
  ),
  (
    '550e8400-e29b-41d4-a716-446655440006'::uuid,
    '550e8400-e29b-41d4-a716-446655440105'::uuid, -- Replace with actual user_id
    2,
    'acer-nitro-5-gaming-laptop',
    5,
    'Exceeded all expectations! Fast processor, amazing display quality, and handles demanding games effortlessly. Build quality is premium. Highly recommended for gamers and professionals.',
    '2025-01-08 13:30:00+00'::timestamptz,
    '2025-01-08 13:30:00+00'::timestamptz
  );

-- Product 3: Lunar Vista Fitness Tracker (product_id = 3)
INSERT INTO public.reviews (id, user_id, product_id, product_name, rating, review_text, created_at, updated_at)
VALUES 
  (
    '550e8400-e29b-41d4-a716-446655440007'::uuid,
    '550e8400-e29b-41d4-a716-446655440106'::uuid, -- Replace with actual user_id
    3,
    'lunar-vista-fitness-tracker',
    4,
    'Great fitness tracker for daily use. Accurate step counting and heart rate monitoring. Sleep tracking feature is helpful. Battery lasts about a week. Good purchase for fitness enthusiasts.',
    '2024-12-18 08:45:00+00'::timestamptz,
    '2024-12-18 08:45:00+00'::timestamptz
  ),
  (
    '550e8400-e29b-41d4-a716-446655440008'::uuid,
    '550e8400-e29b-41d4-a716-446655440107'::uuid, -- Replace with actual user_id
    3,
    'lunar-vista-fitness-tracker',
    4,
    'Very accurate tracking and easy to use. Syncs well with my phone. The display is clear and bright. Only wish it had more sport modes. Overall, a reliable fitness companion.',
    '2025-01-02 15:20:00+00'::timestamptz,
    '2025-01-02 15:20:00+00'::timestamptz
  ),
  (
    '550e8400-e29b-41d4-a716-446655440009'::uuid,
    '550e8400-e29b-41d4-a716-446655440108'::uuid, -- Replace with actual user_id
    3,
    'lunar-vista-fitness-tracker',
    5,
    'Perfect for tracking my fitness goals! All features work flawlessly. Love the waterproof design - I can wear it while swimming. Notifications are timely and battery life is excellent!',
    '2025-01-12 10:00:00+00'::timestamptz,
    '2025-01-12 10:00:00+00'::timestamptz
  );

-- Query to verify the inserts
SELECT 
  product_name,
  COUNT(*) as review_count,
  ROUND(AVG(rating)::numeric, 1) as avg_rating
FROM public.reviews
GROUP BY product_name
ORDER BY product_name;
