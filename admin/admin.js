// Admin Panel JavaScript - Product Management
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm'
import { SUPABASE_CONFIG } from '../config.js'

// Initialize Supabase client
const supabase = createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey)

// Global state
let categories = []
let brands = []
let products = []

// Initialize app
document.addEventListener('DOMContentLoaded', async () => {
  await checkAuth()
  await loadInitialData()
  setupEventListeners()
  setupTabs()
})

// Check authentication
async function checkAuth() {
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    alert('Please login to access admin panel')
    window.location.href = '/auth/login.html'
    return
  }
}

// Load initial data
async function loadInitialData() {
  try {
    await Promise.all([
      loadCategories(),
      loadBrands(),
      loadProducts(),
      loadStats()
    ])
  } catch (error) {
    showAlert('Error loading data: ' + error.message, 'error')
  }
}

// Load categories
async function loadCategories() {
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .eq('is_active', true)
    .order('display_order', { ascending: true })

  if (error) throw error
  
  categories = data
  populateCategorySelects()
}

// Load brands
async function loadBrands() {
  const { data, error } = await supabase
    .from('brands')
    .select('*')
    .eq('is_active', true)
    .order('name', { ascending: true })

  if (error) throw error
  
  brands = data
  populateBrandSelects()
}

// Load products
async function loadProducts() {
  const { data, error } = await supabase
    .from('products')
    .select(`
      *,
      categories(id, name, slug),
      brands(id, name, slug)
    `)
    .order('created_at', { ascending: false })

  if (error) throw error
  
  products = data
  displayProducts(data)
}

// Load statistics
async function loadStats() {
  const { data: allProducts } = await supabase
    .from('products')
    .select('id, is_active')

  const { data: allCategories } = await supabase
    .from('categories')
    .select('id')

  const { data: allBrands } = await supabase
    .from('brands')
    .select('id')

  document.getElementById('totalProducts').textContent = allProducts?.length || 0
  document.getElementById('activeProducts').textContent = 
    allProducts?.filter(p => p.is_active).length || 0
  document.getElementById('totalCategories').textContent = allCategories?.length || 0
  document.getElementById('totalBrands').textContent = allBrands?.length || 0
}

// Populate category selects
function populateCategorySelects() {
  const selects = ['productCategory', 'filterCategory']
  
  selects.forEach(selectId => {
    const select = document.getElementById(selectId)
    if (!select) return
    
    // Keep first option (placeholder)
    const firstOption = select.options[0]
    select.innerHTML = ''
    select.appendChild(firstOption)
    
    categories.forEach(cat => {
      const option = document.createElement('option')
      option.value = cat.id
      option.textContent = cat.name
      select.appendChild(option)
    })
  })
}

// Populate brand selects
function populateBrandSelects() {
  const selects = ['productBrand', 'filterBrand']
  
  selects.forEach(selectId => {
    const select = document.getElementById(selectId)
    if (!select) return
    
    const firstOption = select.options[0]
    select.innerHTML = ''
    select.appendChild(firstOption)
    
    brands.forEach(brand => {
      const option = document.createElement('option')
      option.value = brand.id
      option.textContent = brand.name
      select.appendChild(option)
    })
  })
}

// Display products in table
function displayProducts(productsToDisplay) {
  const tbody = document.getElementById('productsTableBody')
  
  if (!productsToDisplay || productsToDisplay.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; padding: 40px;">No products found</td></tr>'
    return
  }
  
  tbody.innerHTML = productsToDisplay.map(product => `
    <tr>
      <td>
        <img src="${product.image_url || '/Images/placeholder.jpg'}" 
             alt="${product.name}" 
             class="product-img"
             onerror="this.src='/Images/placeholder.jpg'" />
      </td>
      <td>
        <strong>${product.name}</strong><br>
        <small style="color: var(--muted)">${product.slug}</small>
      </td>
      <td>${product.categories?.name || 'N/A'}</td>
      <td>${product.brands?.name || 'N/A'}</td>
      <td>₹${product.price?.toLocaleString()}</td>
      <td>
        ${product.is_active ? '<span class="badge badge-success">Active</span>' : '<span class="badge badge-danger">Inactive</span>'}
        ${product.is_featured ? '<span class="badge badge-featured">Featured</span>' : ''}
      </td>
      <td>
        <div class="actions">
          <button class="btn btn-warning" onclick="editProduct(${product.id})" style="padding: 6px 12px; font-size: 12px;">
            Edit
          </button>
          <button class="btn btn-danger" onclick="deleteProduct(${product.id})" style="padding: 6px 12px; font-size: 12px;">
            Delete
          </button>
        </div>
      </td>
    </tr>
  `).join('')
}

// Setup event listeners
function setupEventListeners() {
  // Add product form
  document.getElementById('addProductForm').addEventListener('submit', handleAddProduct)
  
  // Edit product form
  document.getElementById('editProductForm').addEventListener('submit', handleEditProduct)
  
  // Add category form
  document.getElementById('addCategoryForm').addEventListener('submit', handleAddCategory)
  
  // Add brand form
  document.getElementById('addBrandForm').addEventListener('submit', handleAddBrand)
  
  // Search and filter
  document.getElementById('searchProducts').addEventListener('input', handleSearch)
  document.getElementById('filterCategory').addEventListener('change', handleFilter)
  document.getElementById('filterBrand').addEventListener('change', handleFilter)
  document.getElementById('filterStatus').addEventListener('change', handleFilter)
  
  // Auto-generate slug
  document.getElementById('productName').addEventListener('input', (e) => {
    const slug = generateSlug(e.target.value)
    document.getElementById('productSlug').value = slug
  })
  
  document.getElementById('categoryName').addEventListener('input', (e) => {
    const slug = generateSlug(e.target.value)
    document.getElementById('categorySlug').value = slug
  })
  
  document.getElementById('brandName').addEventListener('input', (e) => {
    const slug = generateSlug(e.target.value)
    document.getElementById('brandSlug').value = slug
  })
  
  // Logout
  document.getElementById('logoutBtn').addEventListener('click', handleLogout)
}

// Setup tabs
function setupTabs() {
  const tabs = document.querySelectorAll('.tab')
  const tabContents = document.querySelectorAll('.tab-content')
  
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const tabName = tab.dataset.tab
      
      tabs.forEach(t => t.classList.remove('active'))
      tabContents.forEach(tc => tc.classList.remove('active'))
      
      tab.classList.add('active')
      document.getElementById(`tab-${tabName}`).classList.add('active')
    })
  })
}

// Generate slug from text
function generateSlug(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

// Handle add product
async function handleAddProduct(e) {
  e.preventDefault()
  
  try {
    const formData = {
      name: document.getElementById('productName').value.trim(),
      slug: document.getElementById('productSlug').value.trim(),
      description: document.getElementById('productDescription').value.trim() || null,
      short_description: document.getElementById('productShortDesc').value.trim() || null,
      price: parseFloat(document.getElementById('productPrice').value),
      original_price: document.getElementById('productOriginalPrice').value 
        ? parseFloat(document.getElementById('productOriginalPrice').value) 
        : null,
      image_url: document.getElementById('productImage').value.trim(),
      category_id: parseInt(document.getElementById('productCategory').value) || null,
      brand_id: document.getElementById('productBrand').value 
        ? parseInt(document.getElementById('productBrand').value) 
        : null,
      model_number: document.getElementById('productModelNumber').value.trim() || null,
      sku: document.getElementById('productSKU').value.trim() || null,
      stock_quantity: parseInt(document.getElementById('productStock').value) || 0,
      amazon_url: document.getElementById('productAmazonUrl').value.trim() || null,
      flipkart_url: document.getElementById('productFlipkartUrl').value.trim() || null,
      is_active: document.getElementById('productActive').checked,
      is_in_stock: document.getElementById('productInStock').checked,
      is_featured: document.getElementById('productFeatured').checked,
      is_trending: document.getElementById('productTrending').checked
    }
    
    // Parse features
    const featuresText = document.getElementById('productFeatures').value.trim()
    if (featuresText) {
      formData.features = featuresText.split(',').map(f => f.trim()).filter(f => f)
    }
    
    // Parse tags
    const tagsText = document.getElementById('productTags').value.trim()
    if (tagsText) {
      formData.tags = tagsText.split(',').map(t => t.trim()).filter(t => t)
    }
    
    // Calculate discount percentage
    if (formData.original_price && formData.price) {
      formData.discount_percentage = Math.round(
        ((formData.original_price - formData.price) / formData.original_price) * 100
      )
    }
    
    const { data, error } = await supabase
      .from('products')
      .insert([formData])
      .select()
    
    if (error) throw error
    
    showAlert('Product added successfully!', 'success')
    document.getElementById('addProductForm').reset()
    await loadProducts()
    await loadStats()
    
  } catch (error) {
    showAlert('Error adding product: ' + error.message, 'error')
  }
}

// Edit product
window.editProduct = async function(productId) {
  try {
    const { data: product, error } = await supabase
      .from('products')
      .select('*')
      .eq('id', productId)
      .single()
    
    if (error) throw error
    
    // Populate edit form
    document.getElementById('editProductId').value = product.id
    document.getElementById('editProductName').value = product.name
    document.getElementById('editProductPrice').value = product.price
    document.getElementById('editProductDescription').value = product.description || ''
    document.getElementById('editProductActive').checked = product.is_active
    document.getElementById('editProductFeatured').checked = product.is_featured
    
    // Show modal
    document.getElementById('editModal').classList.add('active')
    
  } catch (error) {
    showAlert('Error loading product: ' + error.message, 'error')
  }
}

// Handle edit product
async function handleEditProduct(e) {
  e.preventDefault()
  
  try {
    const productId = parseInt(document.getElementById('editProductId').value)
    
    const updates = {
      name: document.getElementById('editProductName').value.trim(),
      price: parseFloat(document.getElementById('editProductPrice').value),
      description: document.getElementById('editProductDescription').value.trim() || null,
      is_active: document.getElementById('editProductActive').checked,
      is_featured: document.getElementById('editProductFeatured').checked
    }
    
    const { error } = await supabase
      .from('products')
      .update(updates)
      .eq('id', productId)
    
    if (error) throw error
    
    showAlert('Product updated successfully!', 'success')
    closeEditModal()
    await loadProducts()
    await loadStats()
    
  } catch (error) {
    showAlert('Error updating product: ' + error.message, 'error')
  }
}

// Delete product
window.deleteProduct = async function(productId) {
  if (!confirm('Are you sure you want to delete this product? This action cannot be undone.')) {
    return
  }
  
  try {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', productId)
    
    if (error) throw error
    
    showAlert('Product deleted successfully!', 'success')
    await loadProducts()
    await loadStats()
    
  } catch (error) {
    showAlert('Error deleting product: ' + error.message, 'error')
  }
}

// Close edit modal
window.closeEditModal = function() {
  document.getElementById('editModal').classList.remove('active')
}

// Handle add category
async function handleAddCategory(e) {
  e.preventDefault()
  
  try {
    const categoryData = {
      name: document.getElementById('categoryName').value.trim(),
      slug: document.getElementById('categorySlug').value.trim(),
      description: document.getElementById('categoryDescription').value.trim() || null,
      is_active: true
    }
    
    const { data, error } = await supabase
      .from('categories')
      .insert([categoryData])
      .select()
    
    if (error) throw error
    
    showAlert('Category added successfully!', 'success')
    document.getElementById('addCategoryForm').reset()
    await loadCategories()
    await loadStats()
    
  } catch (error) {
    showAlert('Error adding category: ' + error.message, 'error')
  }
}

// Handle add brand
async function handleAddBrand(e) {
  e.preventDefault()
  
  try {
    const brandData = {
      name: document.getElementById('brandName').value.trim(),
      slug: document.getElementById('brandSlug').value.trim(),
      website_url: document.getElementById('brandWebsite').value.trim() || null,
      is_active: true
    }
    
    const { data, error } = await supabase
      .from('brands')
      .insert([brandData])
      .select()
    
    if (error) throw error
    
    showAlert('Brand added successfully!', 'success')
    document.getElementById('addBrandForm').reset()
    await loadBrands()
    await loadStats()
    
  } catch (error) {
    showAlert('Error adding brand: ' + error.message, 'error')
  }
}

// Handle search
function handleSearch(e) {
  const searchTerm = e.target.value.toLowerCase()
  const filtered = products.filter(p => 
    p.name.toLowerCase().includes(searchTerm) ||
    p.slug.toLowerCase().includes(searchTerm) ||
    p.description?.toLowerCase().includes(searchTerm)
  )
  displayProducts(filtered)
}

// Handle filter
function handleFilter() {
  const categoryFilter = document.getElementById('filterCategory').value
  const brandFilter = document.getElementById('filterBrand').value
  const statusFilter = document.getElementById('filterStatus').value
  
  let filtered = [...products]
  
  if (categoryFilter) {
    filtered = filtered.filter(p => p.category_id == categoryFilter)
  }
  
  if (brandFilter) {
    filtered = filtered.filter(p => p.brand_id == brandFilter)
  }
  
  if (statusFilter === 'active') {
    filtered = filtered.filter(p => p.is_active)
  } else if (statusFilter === 'inactive') {
    filtered = filtered.filter(p => !p.is_active)
  }
  
  displayProducts(filtered)
}

// Handle logout
async function handleLogout() {
  const { error } = await supabase.auth.signOut()
  
  if (error) {
    showAlert('Error logging out: ' + error.message, 'error')
    return
  }
  
  window.location.href = '/auth/login.html'
}

// Show alert
function showAlert(message, type = 'success') {
  const container = document.getElementById('alertContainer')
  const alert = document.createElement('div')
  alert.className = `alert alert-${type}`
  alert.textContent = message
  
  container.appendChild(alert)
  
  setTimeout(() => {
    alert.remove()
  }, 5000)
}
