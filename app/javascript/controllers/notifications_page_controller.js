import { Controller } from "@hotwired/stimulus"

// Handles real-time notification prepending on the /notifications index page.
// Listens for the same "notifications:received" custom event dispatched by NotificationsChannel.
export default class extends Controller {
   static targets = ["list", "empty"]

   connect() {
      this._handler = (e) => this.onReceived(e.detail)
      window.addEventListener("notifications:received", this._handler)
   }

   disconnect() {
      window.removeEventListener("notifications:received", this._handler)
   }

   onReceived(data) {
      if (data?.type !== "notification") return
      const n = data.notification
      if (!n) return

      // Ẩn thông báo "Chưa có thông báo"
      if (this.hasEmptyTarget) this.emptyTarget.classList.add("d-none")

      // Prepend item mới vào danh sách
      if (this.hasListTarget) {
         this.prependItem(n)
      }
   }

   prependItem(n) {
      const url = n.url || "/notifications"
      const timeStr = n.created_at ? this.formatTime(n.created_at) : "Vừa xong"

      const div = document.createElement("div")
      div.className = "list-group-item d-flex gap-3 align-items-start py-3"
      div.style.background = "#f5f9ff"
      div.innerHTML = `
      <div class="mt-1">
        <span class="d-inline-flex align-items-center justify-content-center rounded-circle"
              style="width:36px;height:36px;background:#e7f1ff;">
          <i class="bi bi-bell-fill"></i>
        </span>
      </div>
      <div class="flex-grow-1">
        <div class="fw-semibold">${this.escapeHtml(n.message)}</div>
        <div class="text-muted small mt-1">${this.escapeHtml(timeStr)}</div>
        <div class="mt-2 d-flex flex-wrap gap-2">
          <a href="${this.escapeHtml(url)}" class="btn btn-sm btn-outline-primary rounded-pill">Xem</a>
          <span class="badge text-bg-primary rounded-pill align-self-center">Mới</span>
        </div>
      </div>
    `

      // Animation: fade-in từ trên xuống
      div.style.opacity = "0"
      div.style.transition = "opacity 0.4s ease, background 1.5s ease"
      this.listTarget.prepend(div)

      requestAnimationFrame(() => {
         requestAnimationFrame(() => {
            div.style.opacity = "1"
            setTimeout(() => { div.style.background = "" }, 1500)
         })
      })
   }

   formatTime(iso) {
      if (!iso) return "Vừa xong"
      try {
         const d = new Date(iso)
         return d.toLocaleString("vi-VN", {
            day: "2-digit", month: "2-digit", year: "numeric",
            hour: "2-digit", minute: "2-digit"
         })
      } catch {
         return "Vừa xong"
      }
   }

   escapeHtml(str) {
      if (!str) return ""
      return String(str)
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
   }
}
