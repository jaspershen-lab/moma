// =====================================================
// Macaque Aging Atlas - Client-side interactions
// =====================================================

function elementMatches(node, selector) {
  if (!node || node.nodeType !== 1) return false;
  var fn = node.matches || node.msMatchesSelector || node.webkitMatchesSelector;
  return !!fn && fn.call(node, selector);
}

function findTissueElement(node) {
  var current = node;
  while (current && current !== document) {
    if (elementMatches(current, "[data-tissue]")) {
      return current;
    }
    current = current.parentNode;
  }
  return null;
}

// Navigation
Shiny.addCustomMessageHandler("navigate", function(page) {
  document.querySelectorAll(".page").forEach(function(p) { p.classList.remove("active"); });
  var target = document.getElementById("page-" + page);
  if (target) target.classList.add("active");

  document.querySelectorAll(".nav-link").forEach(function(l) { l.classList.remove("active"); });
  var navBtn = document.getElementById("nav_" + page);
  if (navBtn) navBtn.classList.add("active");

  window.scrollTo({ top: 0, behavior: "smooth" });
  window.setTimeout(syncAtlasPanelHeight, 60);
});

// SVG tissue interaction
var atlasSelectedTissueId = null;
var atlasHoveredTissue = null;

function getAtlasSvg() {
  return document.getElementById("macaque-svg");
}

function applyAtlasTissueState() {
  var svg = getAtlasSvg();
  if (!svg) return;

  var contextLayers = svg.querySelectorAll(".context-region");
  contextLayers.forEach(function(el) {
    el.style.filter = "";
    el.style.opacity = atlasSelectedTissueId ? "0.35" : "0.78";
  });

  var tissues = svg.querySelectorAll("[data-tissue]");
  tissues.forEach(function(el) {
    el.classList.remove("is-selected", "is-hovered");
    el.style.filter = "";

    if (!atlasSelectedTissueId) {
      el.style.opacity = "0.78";
      return;
    }

    el.style.opacity = el.getAttribute("data-tissue") === atlasSelectedTissueId ? "1" : "0.35";
  });

  if (atlasSelectedTissueId) {
    var selected = svg.querySelector("[data-tissue='" + atlasSelectedTissueId + "']");
    if (selected) {
      selected.classList.add("is-selected");
      selected.style.opacity = "1";
      selected.style.filter = "drop-shadow(0 0 7px rgba(196,89,58,0.55))";
    }
  }

  if (atlasHoveredTissue && svg.contains(atlasHoveredTissue)) {
    atlasHoveredTissue.classList.add("is-hovered");
    atlasHoveredTissue.style.opacity = "1";
    atlasHoveredTissue.style.filter = "drop-shadow(0 0 8px rgba(196,89,58,0.48))";
  }
}

function getAtlasZoomWrapper() {
  return document.querySelector(".anatomy-svg-wrapper");
}

function getAtlasZoomTarget() {
  return document.querySelector(".anatomy-svg-wrapper .anatomy-svg-inline");
}

function syncAtlasPanelHeight() {
  var atlasPage = document.getElementById("page-atlas");
  if (!atlasPage || !atlasPage.classList.contains("active")) return;

  var anatomyPanel = atlasPage.querySelector(".anatomy-panel");
  var atlasRight = atlasPage.querySelector(".atlas-right");
  if (!anatomyPanel || !atlasRight) return;

  if (window.innerWidth <= 860) {
    atlasRight.style.height = "";
    return;
  }

  var panelHeight = anatomyPanel.getBoundingClientRect().height;
  if (panelHeight > 0) {
    atlasRight.style.height = Math.round(panelHeight) + "px";
  }
}

var atlasZoomScale = 1;
var atlasPanX = 0;
var atlasPanY = 0;
var atlasDragState = null;
var atlasDidDrag = false;
var atlasSuppressClick = false;

function clampAtlasPan() {
  var wrapper = getAtlasZoomWrapper();
  var target = getAtlasZoomTarget();
  if (!wrapper || !target) return;

  var maxOffsetX = Math.max(0, (target.clientWidth * atlasZoomScale - wrapper.clientWidth) / 2);
  var maxOffsetY = Math.max(0, (target.clientHeight * atlasZoomScale - wrapper.clientHeight) / 2);

  atlasPanX = Math.max(-maxOffsetX, Math.min(maxOffsetX, atlasPanX));
  atlasPanY = Math.max(-maxOffsetY, Math.min(maxOffsetY, atlasPanY));
}

function syncAtlasZoomClasses() {
  var wrapper = getAtlasZoomWrapper();
  if (!wrapper) return;
  wrapper.classList.toggle("is-zoomed", atlasZoomScale > 1.001);
  wrapper.classList.toggle("is-dragging", !!atlasDragState);
}

function applyAtlasZoom() {
  var target = getAtlasZoomTarget();
  if (!target) return;

  if (atlasZoomScale <= 1.001) {
    atlasPanX = 0;
    atlasPanY = 0;
  }

  clampAtlasPan();
  target.style.transform = "translate(" + atlasPanX + "px, " + atlasPanY + "px) scale(" + atlasZoomScale + ")";
  syncAtlasZoomClasses();
}

function setAtlasZoom(nextScale) {
  atlasZoomScale = Math.max(0.8, Math.min(2.4, nextScale));
  applyAtlasZoom();
}

function stepAtlasZoom(delta) {
  setAtlasZoom(atlasZoomScale + delta);
}

function resetAtlasZoom() {
  atlasZoomScale = 1;
  atlasPanX = 0;
  atlasPanY = 0;
  atlasDragState = null;
  atlasDidDrag = false;
  atlasSuppressClick = false;
  applyAtlasZoom();
}

function pulseAtlasTissue(tissueEl) {
  if (!tissueEl) return;
  tissueEl.classList.remove("is-pulsing");
  tissueEl.getBoundingClientRect();
  tissueEl.classList.add("is-pulsing");
  window.setTimeout(function() {
    tissueEl.classList.remove("is-pulsing");
  }, 280);
}

Shiny.addCustomMessageHandler("highlightTissue", function(tissue_id) {
  atlasSelectedTissueId = tissue_id || null;
  applyAtlasTissueState();
});

// SVG tissue tooltip
var atlasTooltip = null;

function ensureAtlasTooltip() {
  if (atlasTooltip) return atlasTooltip;
  if (!document.body) return null;

  atlasTooltip = document.createElement("div");
  atlasTooltip.className = "atlas-tooltip";
  document.body.appendChild(atlasTooltip);
  return atlasTooltip;
}

function showAtlasTooltip(event, tissueEl) {
  var tissueName = tissueEl.getAttribute("data-tissue-name") || tissueEl.getAttribute("data-tissue") || "";
  var tooltip = ensureAtlasTooltip();
  if (!tooltip || !tissueName) return;
  tooltip.textContent = tissueName;
  tooltip.classList.add("visible");
  moveAtlasTooltip(event);
}

function moveAtlasTooltip(event) {
  var tooltip = ensureAtlasTooltip();
  if (!tooltip || !tooltip.classList.contains("visible")) return;
  tooltip.style.left = (event.clientX + 14) + "px";
  tooltip.style.top = (event.clientY + 14) + "px";
}

function hideAtlasTooltip() {
  var tooltip = ensureAtlasTooltip();
  if (!tooltip) return;
  tooltip.classList.remove("visible");
}

// Initialize SVG interactions once DOM is ready
function initAtlasInteractions() {
  ensureAtlasTooltip();
  resetAtlasZoom();
  syncAtlasPanelHeight();

  document.addEventListener("click", function(e) {
    if (e.target && e.target.id === "anatomy_zoom_in") {
      stepAtlasZoom(0.18);
      return;
    }
    if (e.target && e.target.id === "anatomy_zoom_out") {
      stepAtlasZoom(-0.18);
      return;
    }
    if (e.target && e.target.id === "anatomy_zoom_reset") {
      resetAtlasZoom();
      return;
    }

    if (e.target && e.target.closest && e.target.closest(".anatomy-zoom-controls")) {
      return;
    }

    if (atlasSuppressClick) {
      atlasSuppressClick = false;
      return;
    }

    var tissueEl = findTissueElement(e.target);
    if (!tissueEl) return;

    pulseAtlasTissue(tissueEl);

    var tissueId = tissueEl.getAttribute("data-tissue");
    if (tissueId && window.Shiny && Shiny.setInputValue) {
      Shiny.setInputValue("svg_tissue_click", tissueId, { priority: "event" });
    }
  });

  document.addEventListener("pointerdown", function(e) {
    var wrapper = e.target && e.target.closest ? e.target.closest(".anatomy-svg-wrapper") : null;
    if (!wrapper || atlasZoomScale <= 1.001) return;
    if (e.target && e.target.closest && e.target.closest(".anatomy-zoom-controls")) return;

    atlasDragState = {
      startX: e.clientX,
      startY: e.clientY,
      startPanX: atlasPanX,
      startPanY: atlasPanY,
      moved: false
    };
    atlasDidDrag = false;
    syncAtlasZoomClasses();
  });

  document.addEventListener("pointermove", function(e) {
    if (!atlasDragState) return;

    var dx = e.clientX - atlasDragState.startX;
    var dy = e.clientY - atlasDragState.startY;
    var movedEnough = Math.abs(dx) > 4 || Math.abs(dy) > 4;

    if (!atlasDragState.moved && !movedEnough) {
      return;
    }

    atlasDragState.moved = true;
    atlasDidDrag = true;
    atlasPanX = atlasDragState.startPanX + dx;
    atlasPanY = atlasDragState.startPanY + dy;
    applyAtlasZoom();
  });

  document.addEventListener("pointerup", function() {
    if (!atlasDragState) return;
    atlasSuppressClick = atlasDragState.moved;
    atlasDragState = null;
    syncAtlasZoomClasses();
  });

  document.addEventListener("pointercancel", function() {
    if (!atlasDragState) return;
    atlasSuppressClick = atlasDragState.moved;
    atlasDragState = null;
    syncAtlasZoomClasses();
  });

  document.addEventListener("pointerover", function(e) {
    var tissueEl = findTissueElement(e.target);
    if (!tissueEl) return;

    var relatedTissue = findTissueElement(e.relatedTarget);
    if (relatedTissue === tissueEl) return;

    atlasHoveredTissue = tissueEl;
    applyAtlasTissueState();
    showAtlasTooltip(e, tissueEl);
  });

  document.addEventListener("wheel", function(e) {
    var wrapper = e.target.closest ? e.target.closest(".anatomy-svg-wrapper") : null;
    if (!wrapper) return;

    e.preventDefault();
    stepAtlasZoom(e.deltaY < 0 ? 0.12 : -0.12);
  }, { passive: false });

  document.addEventListener("pointermove", function(e) {
    if (findTissueElement(e.target)) {
      moveAtlasTooltip(e);
    }
  });

  document.addEventListener("pointerout", function(e) {
    var tissueEl = findTissueElement(e.target);
    if (!tissueEl) return;

    var relatedTissue = findTissueElement(e.relatedTarget);
    if (relatedTissue === tissueEl) return;

    atlasHoveredTissue = null;
    applyAtlasTissueState();
    hideAtlasTooltip();
  });

  var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      mutation.addedNodes.forEach(function(node) {
        if (node.classList && node.classList.contains("cluster-cards-grid")) {
          var cards = node.querySelectorAll(".cluster-card");
          cards.forEach(function(card, i) {
            card.style.animationDelay = (i * 0.06) + "s";
          });
        }
      });
    });
  });

  if (document.body) {
    observer.observe(document.body, { childList: true, subtree: true });
  }

  window.addEventListener("resize", syncAtlasPanelHeight);

  if (window.ResizeObserver) {
    var anatomyPanel = document.querySelector(".anatomy-panel");
    if (anatomyPanel) {
      var panelObserver = new ResizeObserver(function() {
        syncAtlasPanelHeight();
      });
      panelObserver.observe(anatomyPanel);
    }
  }
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initAtlasInteractions, { once: true });
} else {
  initAtlasInteractions();
}
