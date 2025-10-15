// Reviews Management System for Smart Buy
// Handles all review-related operations with Supabase backend

import { SUPABASE_CONFIG } from '../config.js';

class ReviewsManager {
  constructor() {
    // Initialize Supabase client
    if (typeof window !== 'undefined' && window.supabase && window.supabase.createClient) {
      const { createClient } = window.supabase;
      this.supabase = createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
      console.log('✅ Reviews Manager - Supabase client initialized');
    } else {
      console.error('❌ Supabase client not available');
      this.supabase = null;
    }
  }

  // Generate consistent product ID from name
  generateProductId(productName) {
    let hash = 0;
    for (let i = 0; i < productName.length; i++) {
      const char = productName.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }

  // Check if user is authenticated
  async checkAuth() {
    if (!this.supabase) return null;
    
    try {
      const { data: { session } } = await this.supabase.auth.getSession();
      return session;
    } catch (error) {
      console.error('Auth check error:', error);
      return null;
    }
  }

  // Submit a new review
  async submitReview(productName, rating, reviewText) {
    if (!this.supabase) {
      throw new Error('Supabase client not initialized');
    }

    try {
      // Check authentication
      const session = await this.checkAuth();
      
      if (!session) {
        throw new Error('User must be logged in to submit a review');
      }

      const productId = this.generateProductId(productName);

      // Insert review into database
      const { data, error } = await this.supabase
        .from('reviews')
        .insert([
          {
            user_id: session.user.id,
            product_id: productId,
            product_name: productName,
            rating: rating,
            review_text: reviewText
          }
        ])
        .select();

      if (error) throw error;

      console.log('✅ Review submitted successfully:', data);
      return { success: true, data: data[0] };
    } catch (error) {
      console.error('❌ Error submitting review:', error);
      return { success: false, error: error.message };
    }
  }

  // Get all reviews for a specific product
  async getProductReviews(productName) {
    if (!this.supabase) {
      console.error('Supabase client not initialized');
      return [];
    }

    try {
      const productId = this.generateProductId(productName);
      
      const { data, error } = await this.supabase
        .from('reviews')
        .select('*')
        .eq('product_id', productId)
        .order('created_at', { ascending: false });

      if (error) throw error;

      console.log(`✅ Loaded ${data.length} reviews for ${productName}`);
      return data;
    } catch (error) {
      console.error('❌ Error loading reviews:', error);
      return [];
    }
  }

  // Get reviews by a specific user
  async getUserReviews(userId) {
    if (!this.supabase) {
      console.error('Supabase client not initialized');
      return [];
    }

    try {
      const { data, error } = await this.supabase
        .from('reviews')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (error) throw error;

      console.log(`✅ Loaded ${data.length} reviews for user`);
      return data;
    } catch (error) {
      console.error('❌ Error loading user reviews:', error);
      return [];
    }
  }

  // Update an existing review
  async updateReview(reviewId, rating, reviewText) {
    if (!this.supabase) {
      throw new Error('Supabase client not initialized');
    }

    try {
      const { data, error } = await this.supabase
        .from('reviews')
        .update({
          rating: rating,
          review_text: reviewText,
          updated_at: new Date().toISOString()
        })
        .eq('id', reviewId)
        .select();

      if (error) throw error;

      console.log('✅ Review updated successfully');
      return { success: true, data: data[0] };
    } catch (error) {
      console.error('❌ Error updating review:', error);
      return { success: false, error: error.message };
    }
  }

  // Delete a review
  async deleteReview(reviewId) {
    if (!this.supabase) {
      throw new Error('Supabase client not initialized');
    }

    try {
      const { error } = await this.supabase
        .from('reviews')
        .delete()
        .eq('id', reviewId);

      if (error) throw error;

      console.log('✅ Review deleted successfully');
      return { success: true };
    } catch (error) {
      console.error('❌ Error deleting review:', error);
      return { success: false, error: error.message };
    }
  }

  // Get average rating for a product
  async getProductRating(productName) {
    if (!this.supabase) {
      return { average: 0, count: 0 };
    }

    try {
      const reviews = await this.getProductReviews(productName);
      
      if (reviews.length === 0) {
        return { average: 0, count: 0 };
      }

      const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
      const average = totalRating / reviews.length;

      return {
        average: Math.round(average * 10) / 10,
        count: reviews.length
      };
    } catch (error) {
      console.error('❌ Error calculating product rating:', error);
      return { average: 0, count: 0 };
    }
  }

  // Get all reviews (for admin purposes)
  async getAllReviews(limit = 100) {
    if (!this.supabase) {
      console.error('Supabase client not initialized');
      return [];
    }

    try {
      const { data, error } = await this.supabase
        .from('reviews')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error) throw error;

      console.log(`✅ Loaded ${data.length} reviews`);
      return data;
    } catch (error) {
      console.error('❌ Error loading all reviews:', error);
      return [];
    }
  }
}

// Export singleton instance
export const reviewsManager = new ReviewsManager();
