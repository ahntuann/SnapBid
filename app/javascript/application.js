// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

/**
 * Apple-style mega menu (desktop only).
 * Works with Turbo: uses turbo:load.
 */
function initAppleMegaNav() {
  const nav = document.querySelector('.apple-navbar[data-apple-mega="true"]')
  if (!nav) return
  if (nav.dataset.megaBound === "1") return
  nav.dataset.megaBound = "1"

  const overlay = nav.querySelector(".apple-mega-overlay")
  const panelsWrap = nav.querySelector(".apple-mega-panels")
  if (!overlay || !panelsWrap) return

  const triggers = Array.from(nav.querySelectorAll(".js-mega-trigger[data-mega]"))
  const panels = Array.from(panelsWrap.querySelectorAll(".apple-mega-panel[data-mega-panel]"))

  const isDesktop = () => window.matchMedia("(min-width: 992px)").matches

  let activeKey = null
  let closeTimer = null

  const getPanel = (key) =>
    panelsWrap.querySelector(`.apple-mega-panel[data-mega-panel="${key}"]`)

  const setExpanded = (key, expanded) => {
    triggers.forEach((t) => {
      if (t.dataset.mega === key) t.setAttribute("aria-expanded", expanded ? "true" : "false")
    })
  }

  const cancelClose = () => {
    if (closeTimer) window.clearTimeout(closeTimer)
    closeTimer = null
  }

  const scheduleClose = (ms = 120) => {
    cancelClose()
    closeTimer = window.setTimeout(() => closeAll(), ms)
  }

  const closeAll = () => {
  if (activeKey) setExpanded(activeKey, false)

  // đóng panel có animation rồi mới hidden
  panels.forEach((p) => {
    p.classList.remove("is-open")
  })

  overlay.classList.remove("is-open")

  const prevKey = activeKey
  activeKey = null

  window.setTimeout(() => {
    // hide sau khi transition xong
    if (!activeKey) {
      panels.forEach((p) => { p.hidden = true })
      overlay.hidden = true
    }
  }, 260)
}


  const openKey = (key) => {
  if (!isDesktop()) return

  if (activeKey && activeKey !== key) setExpanded(activeKey, false)
  activeKey = key

  // show overlay + fade in
  overlay.hidden = false
  requestAnimationFrame(() => overlay.classList.add("is-open"))

  panels.forEach((p) => {
    const match = p.dataset.megaPanel === key

    if (match) {
      p.hidden = false
      // RAF để chắc chắn browser thấy state "đóng" -> "mở" và chạy transition
      requestAnimationFrame(() => p.classList.add("is-open"))
    } else {
      p.classList.remove("is-open")
      // hide sau transition cho panel khác
      window.setTimeout(() => { p.hidden = true }, 260)
    }
  })

  setExpanded(key, true)
}


  // Trigger: hover/focus mở
  triggers.forEach((t) => {
    t.addEventListener("mouseenter", () => {
      cancelClose()
      openKey(t.dataset.mega)
    })

    t.addEventListener("focusin", () => {
      cancelClose()
      openKey(t.dataset.mega)
    })

    // Click: lần 1 mở (không navigate), lần 2 mới đi link
    t.addEventListener("click", (e) => {
      if (!isDesktop()) return
      const key = t.dataset.mega
      const isOpen = activeKey === key && t.getAttribute("aria-expanded") === "true"
      if (!isOpen) {
        e.preventDefault()
        openKey(key)
      }
    })
  })

  // Panel hover giữ mở, rời panel thì đóng
  panels.forEach((p) => {
    p.addEventListener("mouseenter", cancelClose)
    p.addEventListener("mouseleave", () => scheduleClose(140))
  })

  // Overlay: hover vào vùng mờ => đóng như Apple
  overlay.addEventListener("mouseenter", () => scheduleClose(120))
  overlay.addEventListener("click", closeAll)

  // ESC đóng
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeAll()
  })

  // Resize sang mobile => đóng
  window.addEventListener("resize", () => {
    if (!isDesktop()) closeAll()
  })

  // Turbo navigation: trước khi cache page thì đóng để tránh “kẹt”
  document.addEventListener("turbo:before-cache", () => {
    closeAll()
  })
}

document.addEventListener("turbo:load", initAppleMegaNav)


