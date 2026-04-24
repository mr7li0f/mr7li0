/* app.js — dynamic renderer that reads data/content.json and renders sections/subsections */
(function(){
  // Try relative paths first so file:// and simple hosts work
  const CANDIDATE_PATHS = ['./data/content.json','data/content.json'];
  function normalizePath(path){
    if(!path) return path;
    if(/^https?:\/\//i.test(path) || path.startsWith('data:') || path.startsWith('blob:')) return path;
    if(path.startsWith('./') || path.startsWith('../')) return path;
    if(path.startsWith('/')) path = path.slice(1);
    return './' + path;
  }
  const root = document.getElementById('app') || document.querySelector('.container') || document.body;

  function el(tag, attrs={}, children=[]){
    const e = document.createElement(tag);
    for(const k in attrs){
      if(k === 'class') e.className = attrs[k];
      else if(k === 'text') e.textContent = attrs[k];
      else e.setAttribute(k, attrs[k]);
    }
    (Array.isArray(children)?children:[children]).forEach(c=>{if(!c) return; if(typeof c === 'string') e.appendChild(document.createTextNode(c)); else e.appendChild(c)});
    return e;
  }

  function safeHTML(parent, html){
    // Minimal approach: create element and set innerHTML from trusted source (you control repo)
    const wrapper = document.createElement('div');
    wrapper.innerHTML = html || '';
    parent.appendChild(wrapper);
  }

  function renderSection(section){
    const s = el('section',{class:'section',id:section.id||''});
    s.appendChild(el('div',{class:'title',text:section.title || 'Untitled'}));

    if(section.description) safeHTML(s, `<p class="section-desc">${section.description}</p>`);

    if(Array.isArray(section.subsections) && section.subsections.length){
      const grid = el('div',{class:'grid'});
      // If subsections marked as 'asCards' render card grid
      if(section.layout === 'cards'){
          section.subsections.sort((a,b)=>(a.order||0)-(b.order||0)).forEach(sub=>{
          const card = el('article',{class:'project-card'});
          if(sub.image) card.appendChild(el('img',{src:normalizePath(sub.image),alt:sub.title||'',class:'thumb'}));
          card.appendChild(el('h3',{text:sub.title||'Project'}));
          if(sub.summary) card.appendChild(el('p',{text:sub.summary}));
          grid.appendChild(card);
        });
        s.appendChild(grid);
      } else {
        section.subsections.sort((a,b)=>(a.order||0)-(b.order||0)).forEach(sub=>{
          const item = el('div',{class:'subsection'});
          if(sub.image) item.appendChild(el('img',{src:normalizePath(sub.image),alt:sub.title||'',class:'thumb'}));
          const body = el('div',{class:'body'});
          body.appendChild(el('h3',{text:sub.title||'Item'}));
          if(sub.content) safeHTML(body, `<p>${sub.content}</p>`);
          if(sub.links){
            const linksWrap = el('div',{class:'links'});
            (sub.links||[]).forEach(l=>{linksWrap.appendChild(el('a',{href:l.url, text:l.label, target:'_blank'}));});
            body.appendChild(linksWrap);
          }
          item.appendChild(body);
          s.appendChild(item);
        });
      }
    }

    return s;
  }

  function render(data){
    root.innerHTML = '';
    if(data.site && data.site.title){
      const header = el('header',{class:'hero-section'});
      header.appendChild(el('div',{class:'hero-content'},[el('h1',{text:data.site.title}), data.site.subtitle?el('div',{class:'subtitle',text:data.site.subtitle}):null]));
      root.appendChild(header);
    }

    (data.sections || []).filter(s=> s.visible !== false).sort((a,b)=>(a.order||0)-(b.order||0)).forEach(section=>{
      root.appendChild(renderSection(section));
    });

    const footer = el('footer',{class:'footer',text:(data.site && data.site.footer) || '© '+(new Date()).getFullYear()});
    root.appendChild(footer);
  }

  async function fetchAndRender(){
    let json = null;
    for(const p of CANDIDATE_PATHS){
      try{
        const res = await fetch(p, {cache: 'no-cache'});
        if(res && res.ok){
          json = await res.json();
          break;
        }
      }catch(e){
        // ignore and try next path
      }
    }

    if(!json){
      // Don't overwrite the entire page on fetch failure (avoids hiding the HTML when fetch fails on GH Pages)
      console.warn('Failed to fetch data/content.json from candidate paths:', CANDIDATE_PATHS);
      return;
    }

    try{ render(json); }catch(e){ console.error(e); root.innerHTML = '<p class="loading">خطأ في عرض المحتوى</p>' }
  }

  // Run on load
  if(document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fetchAndRender); else fetchAndRender();
})();
