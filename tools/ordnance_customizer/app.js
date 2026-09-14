/**
 * B-2 Spirit — Ordnance Personalization Studio
 * Live Three.js PBR Viewport & Local Bridge Client
 */

// State
let manifest = {
  mission: {
    callsign: "GRIM 21",
    pilot_name: "Capt Mitchell",
    date: "14 SEP 2026",
    sortie_id: "SORTIE-B2-041"
  },
  slots: {
    slot1: {
      bay: 1,
      serial: "MOAB-2026-0061",
      medium: "marker",
      color: [255, 255, 230],
      port_text: "EAT SHIT!\n— 13th Bomb Squadron",
      starboard_text: "FOR FREEDOM ★\nWhiteman AFB sends regards",
      patch: "13th_BS_Grim_Reapers_Patch.png",
      weathering: 0.35,
      seed: 1337
    },
    slot2: {
      bay: 2,
      serial: "MOAB-2026-0062",
      medium: "chalk",
      color: [240, 245, 255],
      port_text: "ENJOY!\nDirect Airmail Delivery",
      starboard_text: "HOPE YOU LIKE OUR NEW TOY!\n(USAF 509th BW)",
      patch: "13th_BS_Grim_Reapers_Patch.png",
      weathering: 0.45,
      seed: 9001
    }
  }
};

let currentSlotKey = "slot1";
let currentSide = "port"; // "port" or "starboard"
let activeStore = "MOAB"; // "MOAB" or "GBU31"

// Three.js Globals
let scene, camera, renderer, controls;
let bombMesh, pbrMaterial, dynamicTexture, textureCanvas, textureCtx;

// DOM Elements
const container = document.getElementById("threejs-container");
const storeMoabBtn = document.getElementById("store-moab-btn");
const storeJdamBtn = document.getElementById("store-jdam-btn");
const slot1Tab = document.getElementById("slot1-tab");
const slot2Tab = document.getElementById("slot2-tab");
const sidePortBtn = document.getElementById("side-port-btn");
const sideStbdBtn = document.getElementById("side-stbd-btn");
const activeSideBadge = document.getElementById("active-side-badge");
const inscriptionInput = document.getElementById("inscription-input");
const charCounter = document.getElementById("char-counter");
const wearSlider = document.getElementById("wear-slider");
const wearLabel = document.getElementById("wear-label");
const callsignInput = document.getElementById("callsign-input");
const pilotInput = document.getElementById("pilot-input");
const serialInput = document.getElementById("serial-input");
const sortieInput = document.getElementById("sortie-input");
const btnCommit = document.getElementById("btn-commit");
const feedbackMsg = document.getElementById("commit-feedback");

// Initialize Studio
window.addEventListener("DOMContentLoaded", async () => {
  setupDynamicTexture();
  initThreeJS();
  await fetchManifest();
  bindUIEvents();
  syncUIFromState();
  updateTexture();
});

// Setup 2D Canvas for Live PBR Texture
function setupDynamicTexture() {
  textureCanvas = document.createElement("canvas");
  textureCanvas.width = 2048;
  textureCanvas.height = 2048;
  textureCtx = textureCanvas.getContext("2d");

  dynamicTexture = new THREE.CanvasTexture(textureCanvas);
  dynamicTexture.wrapS = THREE.RepeatWrapping;
  dynamicTexture.wrapT = THREE.RepeatWrapping;
}

// Three.js 3D Viewport Setup
function initThreeJS() {
  const w = container.clientWidth;
  const h = container.clientHeight;

  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0a0e14);

  camera = new THREE.PerspectiveCamera(40, w / h, 0.1, 100);
  camera.position.set(6.5, 1.8, 3.5);

  renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setSize(w, h);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 1.2;
  container.appendChild(renderer.domElement);

  controls = new THREE.OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  controls.dampingFactor = 0.05;
  controls.maxDistance = 15;
  controls.minDistance = 2;

  // Studio Lighting
  const ambient = new THREE.AmbientLight(0xddeeff, 0.7);
  scene.add(ambient);

  const keyLight = new THREE.DirectionalLight(0xfff5e6, 2.0);
  keyLight.position.set(5, 8, 7);
  scene.add(keyLight);

  const fillLight = new THREE.DirectionalLight(0x6699cc, 1.2);
  fillLight.position.set(-6, -2, -5);
  scene.add(fillLight);

  const rimLight = new THREE.DirectionalLight(0x00e5ff, 1.0);
  rimLight.position.set(0, 4, -8);
  scene.add(rimLight);

  build3DMOAB();

  window.addEventListener("resize", onWindowResize);
  animate();
}

// Procedural 3D GBU-43/B MOAB Construction
function build3DMOAB() {
  const group = new THREE.Group();

  pbrMaterial = new THREE.MeshStandardMaterial({
    map: dynamicTexture,
    roughness: 0.65,
    metalness: 0.15,
  });

  const bodyGeo = new THREE.CylinderGeometry(0.8, 0.8, 5.5, 48, 1, true);
  bodyGeo.rotateZ(Math.PI / 2);
  const bodyMesh = new THREE.Mesh(bodyGeo, pbrMaterial);
  group.add(bodyMesh);

  const noseGeo = new THREE.ConeGeometry(0.8, 2.2, 48, 1, false);
  noseGeo.rotateZ(-Math.PI / 2);
  noseGeo.translate(2.75 + 1.1, 0, 0);
  const noseMesh = new THREE.Mesh(noseGeo, pbrMaterial);
  group.add(noseMesh);

  const tailGeo = new THREE.CylinderGeometry(0.8, 0.45, 1.4, 48, 1, false);
  tailGeo.rotateZ(Math.PI / 2);
  tailGeo.translate(-2.75 - 0.7, 0, 0);
  const tailMesh = new THREE.Mesh(tailGeo, pbrMaterial);
  group.add(tailMesh);

  const finMat = new THREE.MeshStandardMaterial({ color: 0x3d4734, metalness: 0.3, roughness: 0.7 });
  for (let i = 0; i < 4; i++) {
    const angle = (i * Math.PI) / 2;
    const finGeo = new THREE.BoxGeometry(1.2, 0.08, 0.7);
    const fin = new THREE.Mesh(finGeo, finMat);
    fin.position.set(-3.6, Math.sin(angle) * 0.9, Math.cos(angle) * 0.9);
    fin.rotation.x = angle;
    group.add(fin);
  }

  const lugMat = new THREE.MeshStandardMaterial({ color: 0x1f241a, metalness: 0.8, roughness: 0.3 });
  for (const lx of [-1.0, 1.0]) {
    const lugGeo = new THREE.BoxGeometry(0.2, 0.18, 0.08);
    const lug = new THREE.Mesh(lugGeo, lugMat);
    lug.position.set(lx, 0.88, 0);
    group.add(lug);
  }

  scene.add(group);
  bombMesh = group;
}

// Procedural 3D GBU-31 JDAM Construction
function build3DJDAM() {
  const group = new THREE.Group();

  pbrMaterial = new THREE.MeshStandardMaterial({
    map: dynamicTexture,
    roughness: 0.65,
    metalness: 0.15,
  });

  const bodyGeo = new THREE.CylinderGeometry(0.48, 0.48, 3.2, 36, 1, true);
  bodyGeo.rotateZ(Math.PI / 2);
  const bodyMesh = new THREE.Mesh(bodyGeo, pbrMaterial);
  group.add(bodyMesh);

  const noseGeo = new THREE.ConeGeometry(0.48, 1.4, 36, 1, false);
  noseGeo.rotateZ(-Math.PI / 2);
  noseGeo.translate(1.6 + 0.7, 0, 0);
  const noseMesh = new THREE.Mesh(noseGeo, pbrMaterial);
  group.add(noseMesh);

  const tailGeo = new THREE.CylinderGeometry(0.48, 0.40, 1.6, 36, 1, false);
  tailGeo.rotateZ(Math.PI / 2);
  tailGeo.translate(-1.6 - 0.8, 0, 0);
  const tailMesh = new THREE.Mesh(tailGeo, pbrMaterial);
  group.add(tailMesh);

  const finMat = new THREE.MeshStandardMaterial({ color: 0x4f5558, metalness: 0.4, roughness: 0.6 });
  for (let i = 0; i < 4; i++) {
    const angle = (i * Math.PI) / 2 + Math.PI / 4;
    const finGeo = new THREE.BoxGeometry(1.0, 0.05, 0.6);
    const fin = new THREE.Mesh(finGeo, finMat);
    fin.position.set(-2.5, Math.sin(angle) * 0.58, Math.cos(angle) * 0.58);
    fin.rotation.x = angle;
    group.add(fin);
  }

  scene.add(group);
  bombMesh = group;
}

function rebuildStoreMesh() {
  if (bombMesh) {
    scene.remove(bombMesh);
  }
  if (activeStore === "GBU31") {
    build3DJDAM();
  } else {
    build3DMOAB();
  }
}

function onWindowResize() {
  const w = container.clientWidth;
  const h = container.clientHeight;
  camera.aspect = w / h;
  camera.updateProjectionMatrix();
  renderer.setSize(w, h);
}

function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}

// Fetch Manifest from Server
async function fetchManifest() {
  try {
    const res = await fetch("/api/manifest");
    if (res.ok) {
      manifest = await res.json();
      console.log("[STUDIO] Manifest loaded from server:", manifest);
    }
  } catch (e) {
    console.warn("[STUDIO] Server bridge not connected; running local standalone mode.");
    document.getElementById("bridge-status").textContent = "LOCAL STANDALONE";
    document.getElementById("bridge-status").style.color = "#ffb800";
  }
}

// Sync UI Elements from State
function syncUIFromState() {
  const slot = manifest.slots[currentSlotKey];
  const mission = manifest.mission;

  // Tabs
  slot1Tab.classList.toggle("active", currentSlotKey === "slot1");
  slot2Tab.classList.toggle("active", currentSlotKey === "slot2");

  document.getElementById("slot1-summary").textContent = (manifest.slots.slot1.port_text.split("\n")[0] || "BAY 1").slice(0, 16);
  document.getElementById("slot2-summary").textContent = (manifest.slots.slot2.port_text.split("\n")[0] || "BAY 2").slice(0, 16);

  // Side
  sidePortBtn.classList.toggle("active", currentSide === "port");
  sideStbdBtn.classList.toggle("active", currentSide === "starboard");
  activeSideBadge.textContent = currentSide === "port" ? "PORT (LEFT CASING)" : "STARBOARD (RIGHT CASING)";

  // Text
  const currentText = currentSide === "port" ? slot.port_text : slot.starboard_text;
  inscriptionInput.value = currentText;
  updateCharCount(currentText);

  // Medium
  document.querySelectorAll(".medium-btn").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.medium === slot.medium);
  });

  // Weathering
  const wearVal = Math.round(slot.weathering * 100);
  wearSlider.value = wearVal;
  wearLabel.textContent = wearVal < 20 ? `FACTORY FRESH (${wearVal}%)` : (wearVal < 50 ? `TRANSIT SCUFFS (${wearVal}%)` : `COMBAT SORTIE (${wearVal}%)`);

  // Logistics
  callsignInput.value = mission.callsign;
  pilotInput.value = mission.pilot_name;
  serialInput.value = slot.serial;
  sortieInput.value = mission.sortie_id;
}

// Bind UI Events
function bindUIEvents() {
  // Store Switch (MOAB vs GBU-31 JDAM)
  if (storeMoabBtn) {
    storeMoabBtn.addEventListener("click", () => {
      activeStore = "MOAB";
      storeMoabBtn.classList.add("active");
      storeJdamBtn.classList.remove("active");
      rebuildStoreMesh();
      updateTexture();
    });
  }
  if (storeJdamBtn) {
    storeJdamBtn.addEventListener("click", () => {
      activeStore = "GBU31";
      storeJdamBtn.classList.add("active");
      storeMoabBtn.classList.remove("active");
      rebuildStoreMesh();
      updateTexture();
    });
  }

  // Slot Switch
  slot1Tab.addEventListener("click", () => { currentSlotKey = "slot1"; syncUIFromState(); updateTexture(); });
  slot2Tab.addEventListener("click", () => { currentSlotKey = "slot2"; syncUIFromState(); updateTexture(); });

  // Side Switch
  sidePortBtn.addEventListener("click", () => {
    currentSide = "port";
    syncUIFromState();
    cameraToSide("port");
  });
  sideStbdBtn.addEventListener("click", () => {
    currentSide = "starboard";
    syncUIFromState();
    cameraToSide("starboard");
  });

  // Inscription Change
  inscriptionInput.addEventListener("input", (e) => {
    const text = e.target.value;
    if (currentSide === "port") {
      manifest.slots[currentSlotKey].port_text = text;
    } else {
      manifest.slots[currentSlotKey].starboard_text = text;
    }
    updateCharCount(text);
    syncUIFromState();
    updateTexture();
  });

  // Medium Select
  document.querySelectorAll(".medium-btn").forEach(btn => {
    btn.addEventListener("click", () => {
      manifest.slots[currentSlotKey].medium = btn.dataset.medium;
      syncUIFromState();
      updateTexture();
    });
  });

  // Color Select
  document.querySelectorAll(".color-chip").forEach(chip => {
    chip.addEventListener("click", () => {
      document.querySelectorAll(".color-chip").forEach(c => c.classList.remove("active"));
      chip.classList.add("active");
      manifest.slots[currentSlotKey].color = chip.dataset.color.split(",").map(Number);
      updateTexture();
    });
  });

  // Weathering Slider
  wearSlider.addEventListener("input", (e) => {
    manifest.slots[currentSlotKey].weathering = Number(e.target.value) / 100;
    syncUIFromState();
    updateTexture();
  });

  // Logistics Inputs
  callsignInput.addEventListener("input", e => { manifest.mission.callsign = e.target.value; updateTexture(); });
  pilotInput.addEventListener("input", e => { manifest.mission.pilot_name = e.target.value; updateTexture(); });
  serialInput.addEventListener("input", e => { manifest.slots[currentSlotKey].serial = e.target.value; updateTexture(); });
  sortieInput.addEventListener("input", e => { manifest.mission.sortie_id = e.target.value; updateTexture(); });

  // Camera Presets
  document.getElementById("cam-side-l").addEventListener("click", () => cameraToSide("port"));
  document.getElementById("cam-side-r").addEventListener("click", () => cameraToSide("starboard"));
  document.getElementById("cam-top").addEventListener("click", () => {
    camera.position.set(0, 7.5, 0.1);
    controls.target.set(0, 0, 0);
  });
  document.getElementById("cam-reset").addEventListener("click", () => {
    camera.position.set(6.5, 1.8, 3.5);
    controls.target.set(0, 0, 0);
  });

  // Commit Button
  btnCommit.addEventListener("click", commitLoadout);
}

function cameraToSide(side) {
  if (side === "port") {
    // Look directly at Left side
    camera.position.set(0, 0.5, 6.5);
    controls.target.set(0, 0, 0);
  } else {
    // Look directly at Right side
    camera.position.set(0, 0.5, -6.5);
    controls.target.set(0, 0, 0);
  }
}

function updateCharCount(text) {
  const line1 = text.split("\n")[0] || "";
  charCounter.textContent = `${line1.length} / 32 CHARS (LINE 1)`;
  charCounter.style.color = line1.length > 32 ? "#ff4444" : "#94a3b8";
}

// Live Texture Painting onto Canvas
function updateTexture() {
  const ctx = textureCtx;
  const w = textureCanvas.width;
  const h = textureCanvas.height;
  const slot = manifest.slots[currentSlotKey];
  const mission = manifest.mission;

  // 1. Olive Drab Base
  ctx.fillStyle = "#48543a";
  ctx.fillRect(0, 0, w, h);

  if (activeStore === "GBU31") {
    // GBU-31 JDAM Layout
    // Gray Guidance Kit Tail Section
    ctx.fillStyle = "#4e5558";
    ctx.fillRect(0, h * 0.68, w, h * 0.32);

    // Yellow Hazard Band near Nose
    ctx.fillStyle = "#ebb21e";
    ctx.fillRect(0, h * 0.12, w, h * 0.04);

    // White GPS Radome on Tail
    ctx.fillStyle = "#d2d7d2";
    ctx.beginPath();
    ctx.arc(w * 0.5, h * 0.85, w * 0.04, 0, Math.PI * 2);
    ctx.fill();

    // Stencils (Port & Starboard)
    ctx.fillStyle = "#191b1a";
    ctx.font = "24px 'Chakra Petch', monospace";
    ctx.fillText(`GBU-31(V)3/B JDAM • 2000 LB BLU-109`, w * 0.65, h * 0.25);
    ctx.fillText(`SN: ${slot.serial} • ${mission.callsign}`, w * 0.65, h * 0.28);
    ctx.fillText(`PILOT: ${mission.pilot_name.toUpperCase()}`, w * 0.65, h * 0.31);

    ctx.fillText(`GBU-31(V)3/B JDAM • 2000 LB BLU-109`, w * 0.15, h * 0.25);
    ctx.fillText(`SN: ${slot.serial} • ${mission.callsign}`, w * 0.15, h * 0.28);
    ctx.fillText(`PILOT: ${mission.pilot_name.toUpperCase()}`, w * 0.15, h * 0.31);

    // Inscriptions on Bomb Body
    drawInscriptionOnCanvas(ctx, slot.port_text, slot.medium, slot.color, w * 0.60, h * 0.44, -4);
    drawInscriptionOnCanvas(ctx, slot.starboard_text, slot.medium, slot.color, w * 0.10, h * 0.44, 4);

  } else {
    // GBU-43/B MOAB Layout
    // 2. Yellow Hazard Bands
    ctx.fillStyle = "#ebb21e";
    ctx.fillRect(0, h * 0.16, w, h * 0.06);
    ctx.fillRect(0, h * 0.51, w, h * 0.04);

    // 3. Panel Seam Lines
    ctx.strokeStyle = "#38422d";
    ctx.lineWidth = 4;
    for (const frac of [0.12, 0.28, 0.52, 0.72, 0.88]) {
      ctx.beginPath();
      ctx.moveTo(0, h * frac);
      ctx.lineTo(w, h * frac);
      ctx.stroke();
    }

    // 4. Stencils (Port & Starboard)
    ctx.fillStyle = "#191b1a";
    ctx.font = "24px 'Chakra Petch', monospace";
    
    // Port Side Stencils
    ctx.fillText(`GBU-43/B MOAB • WT 21,600 LBS`, w * 0.70, h * 0.25);
    ctx.fillText(`SN: ${slot.serial} • ${mission.callsign}`, w * 0.70, h * 0.28);
    ctx.fillText(`PILOT: ${mission.pilot_name.toUpperCase()}`, w * 0.70, h * 0.31);
    ctx.fillText(`DATE: ${mission.date} • 509 BW`, w * 0.70, h * 0.34);

    // Starboard Side Stencils
    ctx.fillText(`GBU-43/B MOAB • WT 21,600 LBS`, w * 0.20, h * 0.25);
    ctx.fillText(`SN: ${slot.serial} • ${mission.callsign}`, w * 0.20, h * 0.28);
    ctx.fillText(`PILOT: ${mission.pilot_name.toUpperCase()}`, w * 0.20, h * 0.31);
    ctx.fillText(`DATE: ${mission.date} • 509 BW`, w * 0.20, h * 0.34);

    // 5. Inscriptions (Port Side)
    drawInscriptionOnCanvas(ctx, slot.port_text, slot.medium, slot.color, w * 0.65, h * 0.52, -5);

    // 6. Inscriptions (Starboard Side)
    drawInscriptionOnCanvas(ctx, slot.starboard_text, slot.medium, slot.color, w * 0.15, h * 0.52, 4);
  }

  dynamicTexture.needsUpdate = true;
}

function drawInscriptionOnCanvas(ctx, text, medium, color, x, y, angle) {
  if (!text.trim()) return;

  ctx.save();
  ctx.translate(x, y);
  ctx.rotate((angle * Math.PI) / 180);

  const lines = text.split("\n");
  ctx.font = "bold 64px 'Permanent Marker', cursive, sans-serif";
  ctx.fillStyle = `rgb(${color.join(",")})`;
  ctx.shadowColor = "rgba(0,0,0,0.6)";
  ctx.shadowBlur = medium === "chalk" ? 12 : 6;
  ctx.shadowOffsetX = 3;
  ctx.shadowOffsetY = 3;

  let curY = 0;
  for (const line of lines) {
    ctx.fillText(line, 0, curY);
    curY += 74;
  }

  ctx.restore();
}

// Commit Loadout
async function commitLoadout() {
  btnCommit.disabled = true;
  btnCommit.style.opacity = "0.6";
  feedbackMsg.className = "feedback-msg";
  feedbackMsg.textContent = "⚙️ BAKING PBR TEXTURES & SYNCING TO DCS WORLD...";

  try {
    const res = await fetch("/api/commit", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(manifest),
    });

    const data = await res.json();
    if (res.ok && data.status === "success") {
      feedbackMsg.className = "feedback-msg success";
      feedbackMsg.textContent = "🏆 LOADOUT COMMITTED! LIVE PBR MAPS SYNCED TO DCS.";
    } else {
      feedbackMsg.className = "feedback-msg error";
      feedbackMsg.textContent = `❌ ERROR: ${data.message || data.error}`;
    }
  } catch (e) {
    feedbackMsg.className = "feedback-msg error";
    feedbackMsg.textContent = `❌ CONNECTION ERROR: Ensure bridge server is running!`;
  } finally {
    btnCommit.disabled = false;
    btnCommit.style.opacity = "1";
  }
}
