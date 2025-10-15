# Reviews System Documentation

## Overview
The Smart Buy reviews system allows authenticated users to submit, view, update, and delete product reviews. The system is fully integrated with Supabase backend for data persistence and real-time updates.

## Database Schema

### Table: `public.reviews`

```sql
create table public.reviews (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null,
  product_id integer not null,
  product_name text not null,
  rating integer not null,
  review_text text not null,
  created_at timestamp with time zone not null default timezone('utc'::text, now()),
  updated_at timestamp with time zone not null default timezone('utc'::text, now()),
  constraint reviews_pkey primary key (id),
  constraint reviews_user_id_fkey foreign key (user_id) references auth.users(id) on delete cascade,
  constraint reviews_rating_check check (rating >= 1 and rating <= 5)
);
```

### Indexes
- `idx_reviews_user_id` - For fast user review lookups
- `idx_reviews_product_id` - For fast product review lookups
- `idx_reviews_created_at` - For chronological sorting

## Features

### 1. Submit Reviews
- **Authentication Required**: Yes
- **Validation**: 
  - Product must be selected
  - Rating: 1-5 stars (required)
  - Review text: Required, non-empty
- **Auto-capture**: User ID, timestamps

### 2. View Reviews
- **Authentication Required**: No (public access)
- **Display**: 
  - Reviews sorted by newest first
  - Shows rating (stars), date, and review text
  - Loads automatically when product is selected

### 3. Product Rating
- Displays average rating and total review count
- Real-time calculation from all reviews

### 4. User Reviews Management
- Users can view all their submitted reviews
- Edit and delete own reviews (future feature)

## Setup Instructions

### Step 1: Apply Database Schema
1. Open your Supabase project dashboard
2. Go to SQL Editor
3. Run the schema from `supabase-schema-enhanced.sql` (if not already applied)

### Step 2: Enable Row Level Security (RLS)
1. Open SQL Editor in Supabase
2. Run the policies from `reviews-rls-policies.sql`
3. This ensures:
   - Anyone can view reviews
   - Only authenticated users can submit reviews
   - Users can only edit/delete their own reviews

### Step 3: Configure Supabase Connection
Ensure `config.js` has your correct credentials:
```javascript
export const SUPABASE_CONFIG = {
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY'
};
```

### Step 4: Include Required Scripts
The review page needs these scripts (already added to `reviewpage.html`):
```html
<!-- Supabase Client Library -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

<!-- Your config (as module) -->
<script type="module" src="../config.js"></script>
```

## File Structure

```
HomePage/
├── reviewpage.html      # Main review page with form and display
├── reviews.js          # Reviews manager class (reusable module)

auth/
├── auth.js             # Authentication manager

config.js               # Supabase configuration
reviews-rls-policies.sql # RLS security policies
```

## API Reference

### ReviewsManager Class

#### Methods

**`submitReview(productName, rating, reviewText)`**
- Submits a new review to the database
- Returns: `{ success: boolean, data?: object, error?: string }`
- Requires: User authentication

**`getProductReviews(productName)`**
- Fetches all reviews for a specific product
- Returns: Array of review objects
- Public access (no auth required)

**`getUserReviews(userId)`**
- Fetches all reviews by a specific user
- Returns: Array of review objects
- Requires: User authentication

**`updateReview(reviewId, rating, reviewText)`**
- Updates an existing review
- Returns: `{ success: boolean, data?: object, error?: string }`
- Requires: User must own the review

**`deleteReview(reviewId)`**
- Deletes a review
- Returns: `{ success: boolean, error?: string }`
- Requires: User must own the review

**`getProductRating(productName)`**
- Calculates average rating for a product
- Returns: `{ average: number, count: number }`
- Public access

**`getAllReviews(limit)`**
- Fetches all reviews (admin function)
- Returns: Array of review objects
- Default limit: 100

## Usage Examples

### Submit a Review
```javascript
import { reviewsManager } from './reviews.js';

const result = await reviewsManager.submitReview(
  "Nike AirZoom",
  5,
  "Great shoes! Very comfortable."
);

if (result.success) {
  console.log("Review submitted:", result.data);
} else {
  console.error("Error:", result.error);
}
```

### Load Product Reviews
```javascript
const reviews = await reviewsManager.getProductReviews("Nike AirZoom");
console.log(`Found ${reviews.length} reviews`);
```

### Get Product Rating
```javascript
const rating = await reviewsManager.getProductRating("Nike AirZoom");
console.log(`Average: ${rating.average} stars (${rating.count} reviews)`);
```

## Security

### Row Level Security (RLS)
- **Enabled**: Yes
- **Read Access**: Public (anyone can view reviews)
- **Write Access**: Authenticated users only
- **Update/Delete**: Users can only modify their own reviews

### Authentication
- Uses Supabase Auth
- JWT token-based authentication
- Session management handled automatically
- Redirects to login if not authenticated

## Testing

### Manual Testing Checklist

1. **Without Authentication**
   - [ ] Can view existing reviews
   - [ ] Cannot submit reviews (redirected to login)

2. **With Authentication**
   - [ ] Can select a product
   - [ ] Can rate with stars (1-5)
   - [ ] Can write review text
   - [ ] Can submit review successfully
   - [ ] Review appears immediately after submission
   - [ ] Form clears after successful submission

3. **Data Validation**
   - [ ] Cannot submit without product selection
   - [ ] Cannot submit without rating
   - [ ] Cannot submit with empty review text
   - [ ] Rating must be between 1-5

4. **Display**
   - [ ] Reviews load when product is selected
   - [ ] Reviews sorted by newest first
   - [ ] Star rating displayed correctly
   - [ ] Date formatted properly

## Troubleshooting

### Reviews Not Submitting
1. Check browser console for errors
2. Verify user is authenticated: `supabaseClient.auth.getSession()`
3. Check Supabase dashboard for RLS policy issues
4. Verify network requests in DevTools

### Reviews Not Displaying
1. Check if reviews exist in Supabase dashboard
2. Verify `product_id` generation is consistent
3. Check console for loading errors
4. Ensure RLS policies allow SELECT for public

### Authentication Issues
1. Verify Supabase URL and anon key in `config.js`
2. Check if user session is valid
3. Clear browser cache and cookies
4. Re-login if session expired

## Future Enhancements

- [ ] Edit existing reviews
- [ ] Delete reviews with confirmation
- [ ] Add review images/photos
- [ ] Like/helpful button for reviews
- [ ] Report inappropriate reviews
- [ ] Verified purchase badge
- [ ] Review filtering and sorting
- [ ] Admin moderation panel

## Support

For issues or questions:
1. Check console logs for error messages
2. Verify Supabase connection status
3. Review RLS policies in Supabase dashboard
4. Check authentication status

## Version History

- **v1.0** (Current) - Initial release with basic CRUD operations
  - Submit reviews
  - View reviews
  - Authentication integration
  - RLS security policies
