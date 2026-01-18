import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["badge", "panel", "list", "empty"]
  static values = {
    unreadCount: Number
  }

  connect() {
    // init badge
    this.renderBadge(this.unreadCountValue || 0)

    // lắng nghe event từ notifications_channel.js
    this._handler = (e) => this.onReceived(e.detail)
    window.addEventListener("notifications:received", this._handler)
  }

  disconnect() {
    window.removeEventListener("notifications:received", this._handler)
  }

  toggle() {
    if (!this.hasPanelTarget) return
    this.panelTarget.classList.toggle("hidden")
  }

  close() {
    if (!this.hasPanelTarget) return
    this.panelTarget.classList.add("hidden")
  }

  onReceived(data) {
    if (data?.type !== "notification") return
    const n = data.notification
    if (!n) return

    // tăng unread
    const next = (this.unreadCountValue || 0) + (n.read_at ? 0 : 1)
    this.unreadCountValue = next
    this.renderBadge(next)

    // prepend vào list
    this.prependNotification(n)

    // toast đơn giản
    this.toast(n.message)
  }

  renderBadge(count) {
    if (!this.hasBadgeTarget) return
    if (!count || count <= 0) {
      this.badgeTarget.classList.add("hidden")
      this.badgeTarget.innerText = ""
      return
    }
    this.badgeTarget.classList.remove("hidden")
    this.badgeTarget.innerText = String(count)
  }

  prependNotification(n) {
    if (!this.hasListTarget) return

    // ẩn empty text
    if (this.hasEmptyTarget) this.emptyTarget.classList.add("hidden")

    const li = document.createElement("li")
    li.style.padding = "8px"
    li.style.borderBottom = "1px solid #eee"

    const a = document.createElement("a")
    a.href = n.url || "/notifications"
    a.innerText = n.message
    a.style.display = "block"
    a.style.textDecoration = "none"

    const meta = document.createElement("div")
    meta.style.fontSize = "12px"
    meta.style.opacity = "0.7"
    meta.innerText = this.formatTime(n.created_at)

    li.appendChild(a)
    li.appendChild(meta)

    this.listTarget.prepend(li)

    // giữ tối đa 5 items trong dropdown
    while (this.listTarget.children.length > 5) {
      this.listTarget.removeChild(this.listTarget.lastChild)
    }
  }

  formatTime(iso) {
    if (!iso) return ""
    const d = new Date(iso)
    if (Number.isNaN(d.getTime())) return ""
    return d.toLocaleString()
  }

  toast(message) {
    const div = document.createElement("div")
    div.innerText = message
    div.style.position = "fixed"
    div.style.right = "16px"
    div.style.bottom = "16px"
    div.style.zIndex = "9999"
    div.style.background = "#111"
    div.style.color = "#fff"
    div.style.padding = "10px 12px"
    div.style.borderRadius = "10px"
    div.style.maxWidth = "320px"
    div.style.opacity = "0.95"
    document.body.appendChild(div)

    setTimeout(() => div.remove(), 2500)
  }
}
