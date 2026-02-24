// navbar.js — Xử lý logic Mega Menu + Search Overlay cho SnapBid navbar

document.addEventListener("DOMContentLoaded", function () {
  // ============================================================
  // 1. MEGA MENU (hover desktop)
  // ============================================================
  const overlay = document.querySelector(".apple-mega-overlay");
  const panels = document.querySelectorAll(".apple-mega-panel");
  const triggers = document.querySelectorAll(".js-mega-trigger");
  const panelsWrap = document.querySelector(".apple-mega-panels");

  if (!overlay || !triggers.length) return;

  let hideTimer = null;
  let showTimer = null;

  function showPanel(panelId) {
    clearTimeout(hideTimer);

    // Luôn báo hiệu wrapper mở (để lấy nền trắng chung và animation trượt xuống)
    if (panelsWrap) {
      panelsWrap.removeAttribute("hidden");
      void panelsWrap.offsetWidth;
      panelsWrap.classList.add("is-active");
    }

    panels.forEach(p => {
      const shouldShow = p.id === panelId;
      if (shouldShow) {
        p.removeAttribute("hidden");
        void p.offsetWidth; // ép reflow
        p.classList.add("is-open");
      } else {
        p.classList.remove("is-open");
      }
    });

    overlay.removeAttribute("hidden");
    void overlay.offsetWidth;
    overlay.classList.add("is-open");
  }

  function hideAll() {
    hideTimer = setTimeout(() => {
      if (panelsWrap) panelsWrap.classList.remove("is-active");
      panels.forEach(p => p.classList.remove("is-open"));
      overlay.classList.remove("is-open");

      setTimeout(() => {
        const isActiveNow = panelsWrap ? panelsWrap.classList.contains("is-active") : false;
        if (!isActiveNow) {
          overlay.setAttribute("hidden", "");
          panels.forEach(p => p.setAttribute("hidden", ""));
          if (panelsWrap) panelsWrap.setAttribute("hidden", "");
        }
      }, 340);
    }, 150); // Phản xạ đóng
  }

  triggers.forEach(trigger => {
    const panelId = trigger.getAttribute("aria-controls");
    const panel = panelId ? document.getElementById(panelId) : null;

    trigger.addEventListener("mouseenter", () => {
      clearTimeout(hideTimer); // Ngăn chặn việc đóng nếu đang hover nhanh qua lại
      // Chờ 150ms để xác định ý định hover thực sự (Hover Intent)
      showTimer = setTimeout(() => {
        if (panel) showPanel(panelId);
      }, 150);
    });

    trigger.addEventListener("mouseleave", () => {
      clearTimeout(showTimer); // Hủy ý định mở nếu chuột lướt qua quá nhanh
      hideAll();
    });

    if (panel) {
      panel.addEventListener("mouseenter", () => {
        clearTimeout(hideTimer);
        clearTimeout(showTimer);
      });
      panel.addEventListener("mouseleave", () => {
        hideAll();
      });
    }
  });

  // Click overlay → đóng tất cả
  overlay.addEventListener("click", () => {
    clearTimeout(hideTimer);
    if (panelsWrap) {
      panelsWrap.classList.remove("is-active");
      panelsWrap.setAttribute("hidden", ""); // có thể chờ transition hoặc set luôn
    }
    panels.forEach(p => {
      p.classList.remove("is-open");
      p.setAttribute("hidden", "");
    });
    overlay.classList.remove("is-open");
    overlay.setAttribute("hidden", "");
  });

  // ============================================================
  // 2. SEARCH OVERLAY (icon → expand)
  // ============================================================
  const searchBtn = document.getElementById("sb-search-btn");
  const searchOverlay = document.getElementById("sb-search-overlay");
  const searchInput = document.getElementById("sb-search-input");
  const clearBtn = document.getElementById("sb-search-clear");

  if (!searchBtn || !searchOverlay || !searchInput) return;

  function openSearch() {
    searchOverlay.classList.add("is-open");
    searchBtn.setAttribute("aria-expanded", "true");
    // Focus vào input sau khi animation bắt đầu
    setTimeout(() => searchInput.focus(), 60);
  }

  function closeSearch() {
    searchOverlay.classList.remove("is-open");
    searchBtn.setAttribute("aria-expanded", "false");
    searchBtn.focus();
  }

  // Toggle khi bấm nút search
  searchBtn.addEventListener("click", () => {
    const isOpen = searchOverlay.classList.contains("is-open");
    if (isOpen) {
      closeSearch();
    } else {
      openSearch();
    }
  });

  // Nút clear input
  if (clearBtn) {
    clearBtn.addEventListener("click", () => {
      searchInput.value = "";
      clearBtn.classList.remove("visible");
      searchInput.focus();
    });
  }

  // Hiện/ẩn nút clear khi gõ
  searchInput.addEventListener("input", () => {
    if (clearBtn) {
      clearBtn.classList.toggle("visible", searchInput.value.length > 0);
    }
  });

  // Submit form khi nhấn Enter
  searchInput.addEventListener("keydown", e => {
    if (e.key === "Enter") {
      e.preventDefault();
      searchInput.closest("form")?.submit();
    }
    if (e.key === "Escape") {
      closeSearch();
    }
  });

  // Click ngoài overlay → đóng
  document.addEventListener("click", e => {
    if (
      searchOverlay.classList.contains("is-open") &&
      !searchOverlay.contains(e.target) &&
      !searchBtn.contains(e.target)
    ) {
      closeSearch();
    }
  });
});
