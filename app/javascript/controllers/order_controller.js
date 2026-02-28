import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["statusText", "buyerSection", "doneSection", "waitingBadge", "paidAlert"]
  static values = { id: Number, paid: Boolean }

  connect() {
    // 1. WebSocket (realtime)
    this._handler = (e) => this.received(e.detail)
    window.addEventListener("orders:received", this._handler)

    // 2. Polling fallback every 5s (dùng khi WebSocket chậm hoặc qua ngrok)
    if (!this.paidValue) {
      this._poll = setInterval(() => this.pollStatus(), 5000)
    }
  }

  disconnect() {
    window.removeEventListener("orders:received", this._handler)
    clearInterval(this._poll)
  }

  // Nhận từ WebSocket (ActionCable)
  received(data) {
    if (data?.type !== "order_payment_updated") return
    if (Number(data.order?.id) !== this.idValue) return
    this.applyStatus(data.order.status)
  }

  // Polling fallback qua fetch
  async pollStatus() {
    try {
      const res = await fetch(`/orders/${this.idValue}/status`, {
        headers: { "Accept": "application/json", "X-Requested-With": "XMLHttpRequest" }
      })
      if (!res.ok) return
      const data = await res.json()
      this.applyStatus(data.status)
    } catch (_) {}
  }

  // Cập nhật UI theo trạng thái mới
  applyStatus(status) {
    if (this.hasStatusTextTarget) {
      this.statusTextTarget.innerText = status
    }

    if (status === "paid") {
      // Dừng polling
      clearInterval(this._poll)
      this.paidValue = true

      // Ẩn khu vực chờ, hiện khu vực hoàn tất
      if (this.hasBuyerSectionTarget) this.buyerSectionTarget.classList.add("d-none")
      if (this.hasDoneSectionTarget)  this.doneSectionTarget.classList.remove("d-none")

      // Cập nhật badge status
      if (this.hasWaitingBadgeTarget) this.waitingBadgeTarget.classList.add("d-none")

      // Hiển thị toast thông báo
      this._showToast("✅ Thanh toán đã được xác nhận! Đơn hàng hoàn tất.")
    }
  }

  _showToast(message) {
    const toast = document.createElement("div")
    toast.className = "position-fixed bottom-0 end-0 m-3 alert alert-success shadow-lg fw-semibold"
    toast.style.cssText = "z-index:9999;min-width:300px;animation:fadeInUp .3s ease"
    toast.textContent = message
    document.body.appendChild(toast)
    setTimeout(() => toast.remove(), 6000)
  }
}
