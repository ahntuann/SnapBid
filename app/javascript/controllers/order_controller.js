import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["statusText", "buyerSection", "doneSection"]
  static values = { id: Number }

  connect() {
    this._handler = (e) => this.received(e.detail)
    window.addEventListener("orders:received", this._handler)
  }

  disconnect() {
    window.removeEventListener("orders:received", this._handler)
  }

  received(data) {
    if (data?.type !== "order_payment_updated") return
    if (Number(data.order?.id) !== this.idValue) return

    const status = data.order.status
    if (this.hasStatusTextTarget) this.statusTextTarget.innerText = status

    if (status === "paid") {
      if (this.hasBuyerSectionTarget) this.buyerSectionTarget.classList.add("hidden")
      if (this.hasDoneSectionTarget) this.doneSectionTarget.classList.remove("hidden")
    }
  }
}
