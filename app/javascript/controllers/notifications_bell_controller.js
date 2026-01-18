import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["badge", "menu", "list", "toast"]
  static values = { unread: Number }

  connect() {
    this._onReceived = (event) => this.received(event.detail)
    window.addEventListener("notifications:received", this._onReceived)
    this.renderBadge()
  }

  disconnect() {
    window.removeEventListener("notifications:received", this._onReceived)
  }

  toggleMenu() {
    if (!this.hasMenuTarget) return
    this.menuTarget.classList.toggle("hidden")
  }

  received(data) {
    if (!data || data.type !== "notification") return
    const n = data.notification
    if (!n) return

    // 1) tăng badge
    this.unreadValue = (this.unreadValue || 0) + 1
    this.renderBadge()

    // 2) prepend vào list dropdown
    this.prependToList(n)

    // 3) toast popup
    this.showToast(n.message)

    // 4) (tuỳ chọn) nếu menu đang mở thì highlight
    // this.menuTarget?.classList.remove("hidden")
  }

  renderBadge() {
    if (!this.hasBadgeTarget) return
    const count = Number(this.unreadValue || 0)
    if (count <= 0) {
      this.badgeTarget.classList.add("hidden")
      this.badgeTarget.innerText = ""
    } else {
      this.badgeTarget.classList.remove("hidden")
      this.badgeTarget.innerText = count > 99 ? "99+" : String(count)
    }
  }

  prependToList(n) {
    if (!this.hasListTarget) return

    const li = document.createElement("li")
    li.style.padding = "8px"
    li.style.borderBottom = "1px solid #eee"

    const a = document.createElement("a")
    a.href = n.url || "/notifications"
    a.innerText = n.message
    a.style.display = "block"

    // click => mark_read (fire and forget)
    a.addEventListener("click", () => {
      if (n.id) this.markRead(n.id)
    })

    li.appendChild(a)
    this.listTarget.prepend(li)

    // giữ list max 8 items
    while (this.listTarget.children.length > 8) {
      this.listTarget.removeChild(this.listTarget.lastChild)
    }
  }

  showToast(message) {
    if (!this.hasToastTarget) return

    this.toastTarget.innerText = message
    this.toastTarget.classList.remove("hidden")

    clearTimeout(this._toastTimer)
    this._toastTimer = setTimeout(() => {
      this.toastTarget.classList.add("hidden")
      this.toastTarget.innerText = ""
    }, 3500)
  }

  markRead(id) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (!token) return

    fetch(`/notifications/${id}/mark_read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html, text/html, application/json"
      },
      credentials: "same-origin"
    }).catch(() => {})
  }
}
