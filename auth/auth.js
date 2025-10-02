// Authentication Manager for Smart Buy
// This file handles all Supabase authentication operations

import { SUPABASE_CONFIG } from '../config.js';

class AuthManager {
  constructor() {
    // Initialize Supabase client using config
    const SUPABASE_URL = SUPABASE_CONFIG.url;
    const SUPABASE_ANON_KEY = SUPABASE_CONFIG.anonKey;
    
    // Check if Supabase is available
    if (typeof window !== 'undefined' && window.supabase && window.supabase.createClient) {
      this.supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
      console.log('✅ Supabase client initialized successfully');
    } else {
      console.error('❌ Supabase client not available. Make sure the Supabase script is loaded before this module.');
      this.supabase = null;
    }
    
    this.currentUser = null;
    this.initializeAuth();
  }

  async initializeAuth() {
    if (!this.supabase) return;
    
    try {
      // Get initial session
      const { data: { session } } = await this.supabase.auth.getSession();
      this.currentUser = session?.user || null;
      
      // Listen for auth changes
      this.supabase.auth.onAuthStateChange((event, session) => {
        this.currentUser = session?.user || null;
        this.handleAuthStateChange(event, session);
      });
    } catch (error) {
      console.error('Auth initialization error:', error);
    }
  }

  handleAuthStateChange(event, session) {
    switch (event) {
      case 'SIGNED_IN':
        console.log('User signed in:', session.user.email);
        this.updateUIForAuthenticatedUser();
        break;
      case 'SIGNED_OUT':
        console.log('User signed out');
        this.updateUIForUnauthenticatedUser();
        break;
      case 'TOKEN_REFRESHED':
        console.log('Token refreshed');
        break;
    }
  }

  updateUIForAuthenticatedUser() {
    // Update UI elements for authenticated users
    const loginLinks = document.querySelectorAll('[data-auth="login"]');
    const logoutLinks = document.querySelectorAll('[data-auth="logout"]');
    const userInfo = document.querySelectorAll('[data-auth="user-info"]');
    
    loginLinks.forEach(el => el.style.display = 'none');
    logoutLinks.forEach(el => el.style.display = 'flex');
    
    // Update user info if elements exist
    userInfo.forEach(el => {
      el.style.display = 'block';
      el.textContent = this.currentUser?.email || '';
    });

    // Update user profile elements if they exist
    this.updateUserProfile();
  }

  updateUIForUnauthenticatedUser() {
    // Update UI elements for unauthenticated users
    const loginLinks = document.querySelectorAll('[data-auth="login"]');
    const logoutLinks = document.querySelectorAll('[data-auth="logout"]');
    const userInfo = document.querySelectorAll('[data-auth="user-info"]');
    
    loginLinks.forEach(el => el.style.display = 'flex');
    logoutLinks.forEach(el => el.style.display = 'none');
    userInfo.forEach(el => el.style.display = 'none');
  }

  updateUserProfile() {
    // Update user profile elements if they exist
    const userName = document.getElementById('userName');
    const userEmail = document.getElementById('userEmail');
    const userAvatar = document.getElementById('userAvatar');
    
    if (this.currentUser && userName && userEmail && userAvatar) {
      const displayName = this.currentUser.user_metadata?.full_name || this.currentUser.email;
      const email = this.currentUser.email;
      const initial = displayName.charAt(0).toUpperCase();
      
      userName.textContent = displayName;
      userEmail.textContent = email;
      userAvatar.textContent = initial;
    }
  }

  async signUp(email, password, fullName) {
    if (!this.supabase) {
      console.error('❌ Supabase client not available');
      return { success: false, message: 'Authentication service not available. Please refresh the page and try again.' };
    }

    try {
      console.log('🔄 Attempting to sign up user:', email);
      
      const { data, error } = await this.supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName
          }
        }
      });

      if (error) {
        console.error('❌ Signup error:', error);
        return { success: false, message: error.message };
      }

      console.log('✅ User created successfully:', data.user?.email);

      // Try to create user profile, but don't fail signup if this fails
      if (data.user) {
        try {
          const { error: profileError } = await this.supabase
            .from('profiles')
            .insert([
              {
                id: data.user.id,
                full_name: fullName,
                email: email,
                created_at: new Date().toISOString()
              }
            ]);

          if (profileError) {
            console.warn('⚠️ Profile creation error (non-critical):', profileError);
          } else {
            console.log('✅ User profile created successfully');
          }
        } catch (profileError) {
          console.warn('⚠️ Profile creation failed (non-critical):', profileError);
        }
      }

      return {
        success: true,
        message: 'Account created successfully! Please check your email to verify your account.',
        user: data.user
      };
    } catch (error) {
      console.error('Signup error:', error);
      return { success: false, message: 'An unexpected error occurred' };
    }
  }

  async signIn(email, password) {
    if (!this.supabase) {
      console.error('❌ Supabase client not available');
      return { success: false, message: 'Authentication service not available. Please refresh the page and try again.' };
    }

    try {
      console.log('🔄 Attempting to sign in user:', email);
      
      const { data, error } = await this.supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) {
        console.error('❌ Signin error:', error);
        return { success: false, message: error.message };
      }

      console.log('✅ User signed in successfully:', data.user?.email);

      return {
        success: true,
        message: 'Login successful!',
        user: data.user,
        session: data.session
      };
    } catch (error) {
      console.error('❌ Signin error:', error);
      return { success: false, message: 'An unexpected error occurred' };
    }
  }

  async signOut() {
    if (!this.supabase) {
      return { success: false, message: 'Authentication service not available' };
    }

    try {
      const { error } = await this.supabase.auth.signOut();

      if (error) {
        return { success: false, message: error.message };
      }

      return { success: true, message: 'Logged out successfully' };
    } catch (error) {
      console.error('Signout error:', error);
      return { success: false, message: 'An unexpected error occurred' };
    }
  }

  async resetPassword(email) {
    if (!this.supabase) {
      return { success: false, message: 'Authentication service not available' };
    }

    try {
      const { error } = await this.supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/auth/reset-password.html`
      });

      if (error) {
        return { success: false, message: error.message };
      }

      return { success: true, message: 'Password reset email sent!' };
    } catch (error) {
      console.error('Password reset error:', error);
      return { success: false, message: 'An unexpected error occurred' };
    }
  }

  async getCurrentUser() {
    if (!this.supabase) return null;

    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      return user;
    } catch (error) {
      console.error('Get current user error:', error);
      return null;
    }
  }

  async getUserProfile() {
    if (!this.supabase || !this.currentUser) return null;

    try {
      const { data, error } = await this.supabase
        .from('profiles')
        .select('*')
        .eq('id', this.currentUser.id)
        .single();

      if (error) {
        console.error('Profile fetch error:', error);
        return null;
      }

      return data;
    } catch (error) {
      console.error('Get user profile error:', error);
      return null;
    }
  }

  async updateUserProfile(updates) {
    if (!this.supabase || !this.currentUser) {
      return { success: false, message: 'User not authenticated' };
    }

    try {
      const { data, error } = await this.supabase
        .from('profiles')
        .update(updates)
        .eq('id', this.currentUser.id)
        .select()
        .single();

      if (error) {
        return { success: false, message: error.message };
      }

      return { success: true, data };
    } catch (error) {
      console.error('Profile update error:', error);
      return { success: false, message: 'An unexpected error occurred' };
    }
  }

  isAuthenticated() {
    return !!this.currentUser;
  }

  getAccessToken() {
    return this.supabase?.auth.session()?.access_token || null;
  }

  // Helper method to make authenticated API requests
  async makeAuthenticatedRequest(url, options = {}) {
    const token = this.getAccessToken();
    
    if (!token) {
      throw new Error('No access token available');
    }

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      ...options.headers
    };

    return fetch(url, {
      ...options,
      headers
    });
  }

  // Reviews API methods
  async submitReview(productId, productName, rating, reviewText) {
    if (!this.isAuthenticated()) {
      return { success: false, message: 'Please log in to submit a review' };
    }

    try {
      const response = await this.makeAuthenticatedRequest('/api/reviews', {
        method: 'POST',
        body: JSON.stringify({
          productId,
          productName,
          rating,
          reviewText
        })
      });

      const result = await response.json();
      return result;
    } catch (error) {
      console.error('Submit review error:', error);
      return { success: false, message: 'Failed to submit review' };
    }
  }

  async getReviews() {
    try {
      const response = await fetch('/api/reviews');
      const result = await response.json();
      return result;
    } catch (error) {
      console.error('Get reviews error:', error);
      return { success: false, message: 'Failed to fetch reviews' };
    }
  }
}

// Export for use in other files
export { AuthManager };

// Also make it available globally for non-module scripts
if (typeof window !== 'undefined') {
  window.AuthManager = AuthManager;
}
