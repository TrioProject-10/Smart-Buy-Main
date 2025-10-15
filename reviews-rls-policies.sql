-- Row Level Security (RLS) Policies for Reviews Table
-- Apply these policies in your Supabase SQL Editor to secure the reviews table

-- Enable RLS on reviews table
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read reviews (public access)
CREATE POLICY "Anyone can view reviews"
ON public.reviews
FOR SELECT
USING (true);

-- Policy: Authenticated users can insert their own reviews
CREATE POLICY "Authenticated users can insert reviews"
ON public.reviews
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own reviews
CREATE POLICY "Users can update own reviews"
ON public.reviews
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own reviews
CREATE POLICY "Users can delete own reviews"
ON public.reviews
FOR DELETE
USING (auth.uid() = user_id);

-- Optional: Admin policy (if you have an admin role)
-- CREATE POLICY "Admins can manage all reviews"
-- ON public.reviews
-- FOR ALL
-- USING (
--   EXISTS (
--     SELECT 1 FROM public.user_roles
--     WHERE user_id = auth.uid() AND role = 'admin'
--   )
-- );

-- Verify RLS policies
-- Run this to check if policies are applied correctly
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'reviews';
