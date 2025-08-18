import { amazonProducts } from './amazonProducts.js';

const el = s => document.querySelector(s);

function starString(r){ let s=''; for(let i=1;i<=5;i++) s += i<=r ? '★':'☆'; return s; }
function renderProducts(filter='') {
  const grid = el('#productGrid'); grid.innerHTML = '';
  const filtered = amazonProducts.filter(p => p.name.toLowerCase().includes(filter.toLowerCase()));
  el('#count').textContent = filtered.length;
  filtered.forEach(p => {
    const card = document.createElement('div'); card.className = 'card';
    card.innerHTML = `
    <div class="thumb" style="background-image:url('${p.image}')"></div>
    <div class="meta"><h3>${p.name}</h3>
      <div style="display:flex;justify-content:space-between;align-items:center;margin-top:6px">
        <div>
          <div class="price">₹${p.price}</div>
          <div class="actions">
            <a class="pill" href="${p.url}" target="_blank" rel="noopener sponsored nofollow">Buy on Amazon</a>
          </div>
        </div>
      </div>
    </div>`;
    grid.appendChild(card);
  });
}

function renderAll(){ renderProducts(''); }
renderAll();
