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
      this.badgeTarget.classList.add("d-none")
      this.badgeTarget.innerText = ""
    } else {
      this.badgeTarget.classList.remove("d-none")
      this.badgeTarget.innerText = count > 99 ? "99+" : String(count)
    }
  }

  prependToList(n) {
    if (!this.hasListTarget) return

    const temp = document.createElement("div")
    temp.innerHTML = `
      <a href="${n.url || "/notifications"}" 
         class="list-group-item list-group-item-action d-flex gap-3 align-items-start"
         style="background:#f5f9ff;">
        <div class="mt-1">
          <span class="d-inline-flex align-items-center justify-content-center rounded-circle"
                style="width:32px;height:32px;background:#e7f1ff;">
            <i class="bi bi-dot"></i>
          </span>
        </div>
        <div class="flex-grow-1">
          <div class="fw-semibold">${n.message}</div>
          <div class="text-muted small mt-1">Vừa xong</div>
        </div>
        <span class="badge text-bg-primary rounded-pill">Mới</span>
      </a>
    `
    const a = temp.firstElementChild
    a.addEventListener("click", () => {
      if (n.id) this.markRead(n.id)
    })

    this.listTarget.prepend(a)

    // giữ list max 8 items
    while (this.listTarget.children.length > 8) {
      this.listTarget.removeChild(this.listTarget.lastChild)
    }
  }

  showToast(message) {
    if (!this.hasToastTarget) return

    this.toastTarget.innerText = message
    this.toastTarget.classList.remove("d-none")

    clearTimeout(this._toastTimer)
    this._toastTimer = setTimeout(() => {
      this.toastTarget.classList.add("d-none")
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
    }).catch(() => { })
  }
}
