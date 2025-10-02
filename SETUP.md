# Smart Buy - Setup Guide

## 🚀 Quick Setup with Supabase Authentication

### Prerequisites
- Node.js (v16 or higher)
- A Supabase account (free at [supabase.com](https://supabase.com))

### 1. Supabase Setup

1. **Create a new Supabase project:**
   - Go to [supabase.com](https://supabase.com)
   - Click "New Project"
   - Choose your organization and create the project

2. **Get your project credentials:**
   - Go to Settings > API
   - Copy your `Project URL` and `anon public` key

3. **Set up the database:**
   - Go to the SQL Editor in your Supabase dashboard
   - Copy and paste the contents of `supabase-schema.sql`
   - Run the SQL commands to create tables and policies

### 2. Configure the Application

1. **Update configuration files:**
   
   **In `config.js`:**
   ```javascript
   export const SUPABASE_CONFIG = {
     url: 'YOUR_SUPABASE_PROJECT_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY'
   };
   ```

   **In `auth/auth.js`:**
   ```javascript
   const SUPABASE_URL = 'YOUR_SUPABASE_PROJECT_URL';
   const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the server:**
   ```bash
   npm start
   ```

### 3. Features

✅ **Authentication System:**
- User registration with email verification
- Secure login/logout
- Password reset functionality
- Protected routes

✅ **Product Reviews:**
- Browse products with ratings
- Write authenticated reviews
- Real-time review updates
- User profile management

✅ **Modern UI:**
- Responsive design
- Dark theme with gradient accents
- Smooth animations and transitions
- Mobile-friendly interface

### 4. File Structure

```
Smart-Buy-Main/
├── auth/
│   ├── auth.js          # Authentication manager
│   ├── login.html       # Login page
│   └── signup.html      # Registration page
├── Images/              # Product images
├── HomePage/            # Homepage files
├── amazon/              # Amazon integration
├── config.js            # Configuration
├── server.js            # Express server
├── index.html           # Main application
├── supabase-schema.sql  # Database schema
└── package.json         # Dependencies
```

### 5. API Endpoints

- `POST /api/auth/signup` - User registration
- `POST /api/auth/signin` - User login
- `POST /api/auth/signout` - User logout
- `GET /api/user/profile` - Get user profile
- `GET /api/reviews` - Get all reviews
- `POST /api/reviews` - Submit a review (authenticated)

### 6. Environment Variables

Create a `.env` file (optional):
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
PORT=3000
```

### 7. Deployment

**For Vercel/Netlify:**
1. Set environment variables in your deployment platform
2. Update the build commands in `package.json`
3. Deploy the repository

**For traditional hosting:**
1. Upload files to your server
2. Install Node.js dependencies
3. Configure environment variables
4. Start the server with `npm start`

### 8. Customization

**Styling:**
- Update CSS variables in the `<style>` sections
- Modify colors in `:root` CSS variables
- Customize fonts and layouts

**Features:**
- Add more product categories
- Implement advanced search and filtering
- Add user avatars and profiles
- Integrate with external APIs

### 9. Security Features

- Row Level Security (RLS) enabled
- JWT token authentication
- Protected API endpoints
- Input validation and sanitization
- CORS protection

### 10. Troubleshooting

**Common Issues:**

1. **Authentication not working:**
   - Check Supabase credentials in config files
   - Verify database schema is properly set up
   - Check browser console for errors

2. **Reviews not saving:**
   - Ensure user is logged in
   - Check RLS policies in Supabase
   - Verify API endpoints are accessible

3. **Styling issues:**
   - Clear browser cache
   - Check for CSS conflicts
   - Verify image paths are correct

### 11. Support

For issues or questions:
1. Check the browser console for errors
2. Review Supabase logs in the dashboard
3. Verify all configuration files are updated
4. Test with different browsers

---

**Smart Buy** - Your feedback shapes better choices! 🛍️
