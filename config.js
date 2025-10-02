// Supabase Configuration
// Replace these with your actual Supabase project credentials
export const SUPABASE_CONFIG = {
  url: 'https://qbtlzjnjvgktsyddwweo.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFidGx6am5qdmdrdHN5ZGR3d2VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5NTU2MTAsImV4cCI6MjA3NDUzMTYxMH0.AgqwBS279WtIFhRV6lpRTieUyiZuv1b4nvK-UCQwWqI'
};

// Server Configuration (Node.js only)
// Check if we're in a Node.js environment before accessing process
const isNode = typeof process !== 'undefined' && process.versions && process.versions.node;

export const SERVER_CONFIG = {
  port: isNode ? (process.env.PORT || 3001) : 3001,
  environment: isNode ? (process.env.NODE_ENV || 'development') : 'development'
};
