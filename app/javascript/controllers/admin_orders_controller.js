import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._handler = (e) => this.received(e.detail)
    window.addEventListener("orders:received", this._handler)
  }

  disconnect() {
    window.removeEventListener("orders:received", this._handler)
  }

  received(data) {
    if (data?.type !== "order_payment_updated") return

    const id = Number(data.order?.id)
    if (!id) return

    const row = this.element.querySelector(`[data-order-id="${id}"]`)
    if (!row) return

    const statusEl = row.querySelector(`[data-role="status"]`)
    const buyerPaidEl = row.querySelector(`[data-role="buyer_paid"]`)

    if (statusEl) statusEl.innerText = data.order.status
    if (buyerPaidEl) buyerPaidEl.innerText = data.order.buyer_marked_paid_at ? "yes" : "no"

    if (data.order.buyer_marked_paid_at && data.order.status === "pending") {
      row.style.background = "#fff3cd"
      row.style.border = "1px solid #ffe69c"
    }
  }
}
