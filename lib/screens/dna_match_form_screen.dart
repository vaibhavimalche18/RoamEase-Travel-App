
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:var(--font-sans);background:var(--color-background-tertiary);color:var(--color-text-primary)}
.app{max-width:680px;margin:0 auto;padding:16px}
.screen{display:none}.screen.active{display:block}
h1{font-size:20px;font-weight:500;margin-bottom:4px}
.sub{font-size:13px;color:var(--color-text-secondary);margin-bottom:20px}

.card{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);padding:18px;margin-bottom:14px}
.card-title{font-size:13px;font-weight:500;color:var(--color-text-secondary);margin-bottom:12px;display:flex;align-items:center;gap:6px}
.dot{width:8px;height:8px;border-radius:50%;display:inline-block;flex-shrink:0}

.chip-wrap{display:flex;flex-wrap:wrap;gap:6px;margin-top:8px}
.chip{padding:4px 10px;border-radius:99px;font-size:12px;background:var(--color-background-secondary);border:0.5px solid var(--color-border-tertiary);cursor:pointer;transition:all .15s}
.chip.sel{background:#E6F1FB;border-color:#85B7EB;color:#0C447C}
.chip.removable{padding-right:6px;display:flex;align-items:center;gap:4px}
.chip .x{font-size:10px;cursor:pointer;opacity:.6}
.chip .x:hover{opacity:1}

.add-row{display:flex;gap:8px;margin-top:8px}
.add-row input{flex:1;padding:8px 10px;border-radius:8px;border:0.5px solid var(--color-border-secondary);background:var(--color-background-secondary);color:var(--color-text-primary);font-size:13px}
.add-row input:focus{outline:none;border-color:#378ADD}
.add-btn{padding:8px 14px;border-radius:8px;background:var(--color-text-primary);color:var(--color-background-primary);border:none;font-size:13px;cursor:pointer;white-space:nowrap}

.radio-group{display:flex;flex-direction:column;gap:2px}
.radio-opt{display:flex;align-items:center;gap:8px;padding:7px 0;cursor:pointer;font-size:13px;border-bottom:0.5px solid var(--color-border-tertiary)}
.radio-opt:last-child{border-bottom:none}
.radio-opt input{accent-color:#1D9E75}

.switcher{display:flex;gap:0;border:0.5px solid var(--color-border-secondary);border-radius:10px;overflow:hidden;margin-bottom:20px}
.sw-btn{flex:1;padding:10px;text-align:center;font-size:13px;cursor:pointer;background:var(--color-background-primary);border:none;color:var(--color-text-secondary);transition:all .15s}
.sw-btn.active{background:var(--color-text-primary);color:var(--color-background-primary);font-weight:500}

.save-btn{width:100%;padding:13px;border-radius:12px;background:var(--color-text-primary);color:var(--color-background-primary);border:none;font-size:15px;font-weight:500;cursor:pointer;margin-top:8px;transition:opacity .2s}
.save-btn:hover{opacity:.85}

.score-ring{width:130px;height:130px;border-radius:50%;display:flex;flex-direction:column;align-items:center;justify-content:center;margin:0 auto 16px;border-width:6px;border-style:solid}
.score-num{font-size:36px;font-weight:500;line-height:1}
.score-lbl{font-size:12px;color:var(--color-text-secondary);margin-top:2px}

.dna-card{background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);padding:16px;margin-bottom:12px}
.dna-header{display:flex;align-items:center;gap:8px;margin-bottom:10px}
.dna-header .icon{width:24px;height:24px;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0}
.dna-title{font-size:13px;font-weight:500;flex:1}
.dna-count{padding:2px 8px;border-radius:99px;font-size:11px;font-weight:500}

.pill{padding:4px 10px;border-radius:99px;font-size:12px;border:0.5px solid}
.stat-row{display:flex;align-items:center;justify-content:space-between;padding:7px 0;border-bottom:0.5px solid var(--color-border-tertiary);font-size:13px}
.stat-row:last-child{border-bottom:none}
.badge{padding:2px 8px;border-radius:99px;font-size:11px;font-weight:500}
.match{background:#EAF3DE;color:#3B6D11}
.nomatch{background:#F1EFE8;color:#5F5E5A}

.back-btn{display:flex;align-items:center;gap:6px;font-size:14px;cursor:pointer;color:var(--color-text-secondary);margin-bottom:18px}
.back-btn:hover{color:var(--color-text-primary)}
.empty{font-size:12px;color:var(--color-text-tertiary);padding:4px 0}

.tabs{display:flex;gap:0;border-bottom:0.5px solid var(--color-border-tertiary);margin-bottom:20px}
.tab{padding:8px 16px;font-size:13px;cursor:pointer;color:var(--color-text-secondary);border-bottom:2px solid transparent;margin-bottom:-0.5px}
.tab.active{color:var(--color-text-primary);border-bottom-color:var(--color-text-primary)}

.traveler-card{display:flex;align-items:center;gap:12px;padding:14px;background:var(--color-background-primary);border:0.5px solid var(--color-border-tertiary);border-radius:var(--border-radius-lg);cursor:pointer;margin-bottom:10px;transition:border-color .15s}
.traveler-card:hover{border-color:var(--color-border-secondary)}
.avatar{width:44px;height:44px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:16px;font-weight:500;flex-shrink:0}
.trav-info{flex:1}
.trav-name{font-size:14px;font-weight:500}
.trav-sub{font-size:12px;color:var(--color-text-secondary);margin-top:2px}
.score-pill{padding:4px 10px;border-radius:99px;font-size:12px;font-weight:500}
</style>

<div class="app">

<div id="screen-main" class="screen active">
  <div class="switcher">
    <button class="sw-btn active" onclick="showSection('explore')">Explore matches</button>
    <button class="sw-btn" onclick="showSection('profile')">My profile</button>
  </div>

  <div id="sec-explore">
    <h1>Travel DNA matches</h1>
    <p class="sub">Tap a traveler to see your compatibility breakdown</p>
    <div id="traveler-list"></div>
  </div>

  <div id="sec-profile" style="display:none">
    <h1>My travel profile</h1>
    <p class="sub">Fill this in to get accurate match scores</p>

    <div class="card">
      <div class="card-title"><span class="dot" style="background:#378ADD"></span>Places I've visited</div>
      <div class="add-row">
        <input id="v-inp" placeholder="Paris, Bali, Morocco…" onkeydown="if(event.key==='Enter')addPlace('v')" />
        <button class="add-btn" onclick="addPlace('v')">Add</button>
      </div>
      <div class="chip-wrap" id="v-chips"></div>
    </div>

    <div class="card">
      <div class="card-title"><span class="dot" style="background:#D4537E"></span>Dream destinations (wishlist)</div>
      <div class="add-row">
        <input id="w-inp" placeholder="Japan, Patagonia, Iceland…" onkeydown="if(event.key==='Enter')addPlace('w')" />
        <button class="add-btn" onclick="addPlace('w')">Add</button>
      </div>
      <div class="chip-wrap" id="w-chips"></div>
    </div>

    <div class="card">
      <div class="card-title"><span class="dot" style="background:#1D9E75"></span>Travel style — pick all that apply</div>
      <div class="chip-wrap" id="style-chips"></div>
    </div>

    <div class="card">
      <div class="card-title"><span class="dot" style="background:#BA7517"></span>Budget</div>
      <div class="radio-group" id="budget-group"></div>
    </div>

    <div class="card">
      <div class="card-title"><span class="dot" style="background:#7F77DD"></span>Trip duration preference</div>
      <div class="radio-group" id="duration-group"></div>
    </div>

    <div class="card">
      <div class="card-title"><span class="dot" style="background:#378ADD"></span>Travel companion preference</div>
      <div class="radio-group" id="companion-group"></div>
    </div>

    <div class="card">
      <div class="card-title"><span class="dot" style="background:#D85A30"></span>Climate preference</div>
      <div class="radio-group" id="climate-group"></div>
    </div>

    <button class="save-btn" onclick="saveProfile()">Save profile & refresh matches</button>
  </div>
</div>

<div id="screen-match" class="screen">
  <div class="back-btn" onclick="goBack()">← Back</div>
  <div id="match-content"></div>
</div>

</div>

<script>
const STYLES=['Adventure','Backpacker','Luxury','Budget','Solo','Family','Foodie','Culture','Nature','Photography','Nightlife','Wellness','Road Trip','Cruise','Slow Travel'];
const BUDGETS=['Budget (<$50/day)','Mid-range ($50–150/day)','Comfort ($150–300/day)','Luxury ($300+/day)'];
const DURATIONS=['Weekend getaways','Week-long trips','2–4 weeks','Long-term travel'];
const COMPANIONS=['Solo only','Solo or with one partner','Small group (3–5)','Big group (6+)'];
const CLIMATES=['Tropical','Cold & snowy','Dry/Desert','Temperate','Any'];

let myProfile={visited:['Paris','Bali','Tokyo'],wishlist:['Iceland','Patagonia','Morocco'],styles:new Set(['Adventure','Foodie','Solo']),budget:'Mid-range ($50–150/day)',duration:'Week-long trips',companion:'Solo or with one partner',climate:'Temperate'};

const travelers=[
  {id:1,name:'Priya S.',avatar:'PS',color:'#9FE1CB',textColor:'#085041',bio:'Chasing sunsets and street food across Asia.',visited:['Bali','Tokyo','Singapore','Vietnam'],wishlist:['Iceland','New Zealand','Peru'],styles:['Foodie','Culture','Solo','Photography'],budget:'Mid-range ($50–150/day)',duration:'Week-long trips',companion:'Solo or with one partner',climate:'Tropical'},
  {id:2,name:'Marco R.',avatar:'MR',color:'#FAC775',textColor:'#412402',bio:'Backpacker turned digital nomad. Hostels forever.',visited:['Morocco','Portugal','Vietnam','Colombia'],wishlist:['Patagonia','Iceland','Georgia'],styles:['Backpacker','Budget','Adventure'],budget:'Budget (<$50/day)',duration:'Long-term travel',companion:'Solo only',climate:'Temperate'},
  {id:3,name:'Yuki T.',avatar:'YT',color:'#CEC BF6',textColor:'#26215C',bio:'Luxury travel with a touch of zen.',visited:['Paris','Maldives','Kyoto','Dubai'],wishlist:['Iceland','Amalfi Coast','Bora Bora'],styles:['Luxury','Wellness','Culture'],budget:'Luxury ($300+/day)',duration:'Week-long trips',companion:'Solo or with one partner',climate:'Any'},
  {id:4,name:'Aisha K.',avatar:'AK',color:'#F5C4B3',textColor:'#4A1B0C',bio:'Group travel enthusiast. The more the merrier!',visited:['Bali','Morocco','Greece','Turkey'],wishlist:['Japan','Iceland','Kenya'],styles:['Adventure','Culture','Family','Nightlife'],budget:'Mid-range ($50–150/day)',duration:'2–4 weeks',companion:'Small group (3–5)',climate:'Tropical'},
];

function calcScore(other){
  const mv=new Set(myProfile.visited), ov=new Set(other.visited);
  const mw=new Set(myProfile.wishlist), ow=new Set(other.wishlist);
  const ms=myProfile.styles, os=new Set(other.styles);
  const maxV=Math.max(mv.size,ov.size), maxW=Math.max(mw.size,ow.size), maxS=Math.max(ms.size,os.size);
  let score=0;
  const sharedV=[...mv].filter(x=>ov.has(x));
  const sharedW=[...mw].filter(x=>ow.has(x));
  const sharedS=[...ms].filter(x=>os.has(x));
  const youGuide=[...mv].filter(x=>ow.has(x));
  const theyGuide=[...ov].filter(x=>mw.has(x));
  if(maxV>0)score+=sharedV.length/maxV*25;
  if(maxW>0)score+=sharedW.length/maxW*20;
  if(maxS>0)score+=sharedS.length/maxS*20;
  if(myProfile.budget===other.budget)score+=15;
  if(myProfile.companion===other.companion)score+=10;
  if(myProfile.climate===other.climate)score+=5;
  if(myProfile.duration===other.duration)score+=5;
  return{score:Math.round(score),sharedV,sharedW,sharedS,youGuide,theyGuide,
    budgetMatch:myProfile.budget===other.budget,companionMatch:myProfile.companion===other.companion,
    climateMatch:myProfile.climate===other.climate,durationMatch:myProfile.duration===other.duration,
    other};
}

function scoreColor(s){return s>=70?'#1D9E75':s>=40?'#378ADD':'#BA7517'}
function scoreLabel(s){if(s>=80)return'Travel soulmates!';if(s>=60)return'Great travel buddies';if(s>=40)return'Good match';return'Different paths — still interesting!'}

function renderTravelers(){
  const el=document.getElementById('traveler-list');
  const sorted=[...travelers].map(t=>({t,r:calcScore(t)})).sort((a,b)=>b.r.score-a.r.score);
  el.innerHTML=sorted.map(({t,r})=>`
    <div class="traveler-card" onclick="showMatch(${t.id})">
      <div class="avatar" style="background:${t.color};color:${t.textColor}">${t.avatar}</div>
      <div class="trav-info">
        <div class="trav-name">${t.name}</div>
        <div class="trav-sub">${t.bio}</div>
      </div>
      <div class="score-pill" style="background:${scoreColor(r.score)}22;color:${scoreColor(r.score)}">${r.score}%</div>
    </div>
  `).join('');
}

function showMatch(id){
  const t=travelers.find(x=>x.id===id);
  const r=calcScore(t);
  const col=scoreColor(r.score);
  document.getElementById('match-content').innerHTML=`
    <div style="text-align:center;margin-bottom:24px">
      <div class="score-ring" style="border-color:${col}">
        <div class="score-num" style="color:${col}">${r.score}%</div>
        <div class="score-lbl">match</div>
      </div>
      <div style="font-size:17px;font-weight:500;margin-bottom:4px">${scoreLabel(r.score)}</div>
      <div style="font-size:12px;color:var(--color-text-secondary)">Travel DNA with ${t.name}</div>
    </div>

    ${dnaCard('📍','Places you both visited',r.sharedV,'#B5D4F4','#0C447C','#E6F1FB')}
    ${dnaCard('❤️','Shared dream destinations',r.sharedW,'#F4C0D1','#72243E','#FBEAF0')}
    ${dnaCard('🧭','You can guide them',r.youGuide,'#9FE1CB','#085041','#E1F5EE')}
    ${dnaCard('🗺️','They can guide you',r.theyGuide,'#CEC BF6','#3C3489','#EEEDFE')}
    ${dnaCard('✨','Shared travel style',r.sharedS,'#FAC775','#633806','#FAEEDA')}

    <div class="dna-card">
      <div class="dna-header"><div class="icon" style="background:#F1EFE8">⚙️</div><div class="dna-title">Preference breakdown</div></div>
      <div class="stat-row"><span>Budget</span><span class="badge ${r.budgetMatch?'match':'nomatch'}">${r.budgetMatch?'Match':'Different'}</span></div>
      <div class="stat-row"><span>Companion style</span><span class="badge ${r.companionMatch?'match':'nomatch'}">${r.companionMatch?'Match':'Different'}</span></div>
      <div class="stat-row"><span>Climate</span><span class="badge ${r.climateMatch?'match':'nomatch'}">${r.climateMatch?'Match':'Different'}</span></div>
      <div class="stat-row"><span>Trip duration</span><span class="badge ${r.durationMatch?'match':'nomatch'}">${r.durationMatch?'Match':'Different'}</span></div>
      <div class="stat-row" style="border:none;margin-top:4px"><span style="color:var(--color-text-secondary);font-size:12px">Their budget</span><span style="font-size:12px">${t.budget}</span></div>
    </div>
  `;
  document.getElementById('screen-main').classList.remove('active');
  document.getElementById('screen-match').classList.add('active');
}

function dnaCard(icon,title,items,border,textC,bg){
  const chips=items.length?items.map(i=>`<span class="pill" style="background:${bg};border-color:${border};color:${textC}">${i}</span>`).join(''):'<span class="empty">None yet</span>';
  return`<div class="dna-card"><div class="dna-header"><div class="icon" style="background:${bg};font-size:14px">${icon}</div><div class="dna-title">${title}</div><span class="dna-count" style="background:${bg};color:${textC}">${items.length}</span></div><div class="chip-wrap">${chips}</div></div>`;
}

function goBack(){
  document.getElementById('screen-match').classList.remove('active');
  document.getElementById('screen-main').classList.add('active');
}

function showSection(s){
  document.querySelectorAll('.sw-btn').forEach((b,i)=>b.classList.toggle('active',['explore','profile'][i]===s));
  document.getElementById('sec-explore').style.display=s==='explore'?'block':'none';
  document.getElementById('sec-profile').style.display=s==='profile'?'block':'none';
}

function addPlace(type){
  const inp=document.getElementById(type+'-inp');
  const val=inp.value.trim();
  if(!val)return;
  if(type==='v'&&!myProfile.visited.includes(val))myProfile.visited.push(val);
  if(type==='w'&&!myProfile.wishlist.includes(val))myProfile.wishlist.push(val);
  inp.value='';
  renderChips();
}

function removePlace(type,val){
  if(type==='v')myProfile.visited=myProfile.visited.filter(x=>x!==val);
  if(type==='w')myProfile.wishlist=myProfile.wishlist.filter(x=>x!==val);
  renderChips();
}

function renderChips(){
  document.getElementById('v-chips').innerHTML=myProfile.visited.map(p=>`<span class="chip removable" style="background:#E6F1FB;border-color:#85B7EB;color:#0C447C">${p}<span class="x" onclick="removePlace('v','${p}')">✕</span></span>`).join('')||'<span class="empty">None added yet</span>';
  document.getElementById('w-chips').innerHTML=myProfile.wishlist.map(p=>`<span class="chip removable" style="background:#FBEAF0;border-color:#F4C0D1;color:#72243E">${p}<span class="x" onclick="removePlace('w','${p}')">✕</span></span>`).join('')||'<span class="empty">None added yet</span>';
}

function buildStyleChips(){
  const el=document.getElementById('style-chips');
  el.innerHTML=STYLES.map(s=>{
    const sel=myProfile.styles.has(s);
    return`<span class="chip${sel?' sel':''}" onclick="toggleStyle('${s}')">${s}</span>`;
  }).join('');
}

function toggleStyle(s){
  if(myProfile.styles.has(s))myProfile.styles.delete(s);else myProfile.styles.add(s);
  buildStyleChips();
}

function buildRadio(groupId, options, getter, setter){
  document.getElementById(groupId).innerHTML=options.map(o=>`
    <label class="radio-opt"><input type="radio" name="${groupId}" value="${o}" ${getter()===o?'checked':''} onchange="${setter}('${o.replace(/'/g,"\\'")}')"> ${o}</label>
  `).join('');
}

function saveProfile(){
  renderTravelers();
  showSection('explore');
  const b=document.querySelector('button.sw-btn');
  b&&(b.style.background='',b.style.color='');
}

function init(){
  renderChips();
  buildStyleChips();
  buildRadio('budget-group',BUDGETS,()=>myProfile.budget,'setBudget');
  buildRadio('duration-group',DURATIONS,()=>myProfile.duration,'setDuration');
  buildRadio('companion-group',COMPANIONS,()=>myProfile.companion,'setCompanion');
  buildRadio('climate-group',CLIMATES,()=>myProfile.climate,'setClimate');
  renderTravelers();
}

function setBudget(v){myProfile.budget=v}
function setDuration(v){myProfile.duration=v}
function setCompanion(v){myProfile.companion=v}
function setClimate(v){myProfile.climate=v}

init();
</script>
