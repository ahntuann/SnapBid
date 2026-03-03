import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = [
    "currentPrice", "bids", "bidForm", "status", "flash",
    "amount", "amountHidden", "confirmBuyNow", "buyNowBox",
    "bidCount", "minNextBid", "minNextBidHint"
  ]
  static values = {
    id: Number,
    buyNowEnabled: Boolean,
    buyNowPrice: Number,
    auctionEndsAt: String
  }

  connect() {
    const listingId = this.idValue || this.element.dataset.listingId

    this.subscription = consumer.subscriptions.create(
      { channel: "ListingsChannel", listing_id: listingId },
      { received: (data) => this.handleMessage(data) }
    )
    this.scheduleAuctionEnd()
  }

  disconnect() {
    if (this.subscription) consumer.subscriptions.remove(this.subscription)
    if (this._endTimer) clearTimeout(this._endTimer)
  }

  // ── Input formatting: hiển thị 1,000,000 ── //
  formatAndCheck() {
    if (!this.hasAmountTarget) return

    const displayInput = this.amountTarget
    // Strip all non-digits/dots from current display
    const raw = displayInput.value.replace(/[^\d]/g, "")
    const num = parseInt(raw, 10)

    if (raw === "") {
      // Xóa hết → clear hidden
      if (this.hasAmountHiddenTarget) this.amountHiddenTarget.value = ""
      this.hideFlash()
      return
    }

    // Format với dấu phẩy ngăn cách hàng nghìn (vi-VN style)
    const formatted = Number(raw).toLocaleString("vi-VN")
    displayInput.value = formatted

    // Sync raw number vào hidden field (dùng cho submit)
    if (this.hasAmountHiddenTarget) this.amountHiddenTarget.value = raw

    // Kiểm tra buy now threshold
    this.checkBuyNowThresholdValue(num)
  }

  checkBuyNowThresholdValue(amount) {
    if (!this.buyNowEnabledValue) return
    const buyNow = parseFloat(this.buyNowPriceValue || "0")
    if (!buyNow || amount < buyNow) {
      this.hideFlash()
      return
    }
    this.showFlash(`Giá bạn nhập (${this.formatNumber(amount)}) ≥ giá mua ngay (${this.formatNumber(buyNow)}). Nếu bấm "Đặt giá", hệ thống sẽ hỏi để MUA NGAY.`)
  }

  // Keep old action name for backward compat
  checkBuyNowThreshold() {
    if (!this.hasAmountTarget) return
    const raw = this.amountTarget.value.replace(/[^\d]/g, "")
    const num = parseInt(raw || "0", 10)
    this.checkBuyNowThresholdValue(num)
  }

  // ── Submit: chặn để confirm buy-now ── //
  submitBid(event) {
    const form = event.target
    if (form.dataset.skipConfirm === "1") {
      form.dataset.skipConfirm = "0"
      return
    }

    if (!this.hasBuyNowEnabledValue || !this.buyNowEnabledValue) return
    if (!this.hasBuyNowPriceValue || !this.hasConfirmBuyNowTarget) return

    // Read amount from hidden field (raw number) or display field
    let amount = 0
    if (this.hasAmountHiddenTarget && this.amountHiddenTarget.value) {
      amount = Number(this.amountHiddenTarget.value)
    } else if (this.hasAmountTarget) {
      amount = Number(this.amountTarget.value.replace(/[^\d]/g, "") || 0)
    }
    const buyNow = Number(this.buyNowPriceValue || 0)
    if (!amount || !buyNow) return

    if (amount >= buyNow) {
      event.preventDefault()

      const ok = window.confirm(
        `Giá bạn nhập (${this.formatNumber(amount)}) ≥ giá mua ngay (${this.formatNumber(buyNow)}).\n` +
        `Nếu tiếp tục, bạn sẽ MUA NGAY với giá ${this.formatNumber(buyNow)}.\n\n` +
        `Bạn có muốn mua ngay không?`
      )

      if (!ok) {
        this.showFlash("Bạn đã huỷ mua ngay. Vui lòng nhập giá thấp hơn giá mua ngay.")
        return
      }

      this.confirmBuyNowTarget.value = "1"
      form.dataset.skipConfirm = "1"

      const submitter = form.querySelector('input[type="submit"],button[type="submit"]')
      setTimeout(() => {
        if (submitter) form.requestSubmit(submitter)
        else form.requestSubmit()
      }, 0)
    }
  }

  beforeBidSubmit(event) {
    return this.submitBid(event)
  }

  // ── Countdown local timer ── //
  scheduleAuctionEnd() {
    if (!this.hasAuctionEndsAtValue) return
    if (!this.auctionEndsAtValue) return

    const endsAt = Date.parse(this.auctionEndsAtValue)
    if (Number.isNaN(endsAt)) return

    const delay = endsAt - Date.now()
    if (delay <= 0) { this.markAsEndedUI(); return }

    this._endTimer = setTimeout(() => this.markAsEndedUI(), delay)
  }

  markAsEndedUI() {
    if (this._alreadyEnded) return
    this._alreadyEnded = true

    if (this.hasStatusTarget) this.statusTarget.innerText = "Đã kết thúc"
    if (this.hasBidFormTarget) this.bidFormTarget.remove()
    if (this.hasBuyNowBoxTarget) this.buyNowBoxTarget.remove()
    this.showFlash("Phiên đấu giá đã kết thúc.")
  }

  // ── WebSocket handlers ── //
  handleMessage(data) {
    switch (data.type) {
      case "new_bid":
        this.updatePrice(data.current_price)
        this.updateBidCount(data.bid_count)
        this.updateMinNextBid(data.min_next_bid)
        this.prependBid(data.bid)
        break
      case "sold":
        this.markAsSold(data)
        break
      case "ended":
        this.markAsEnded(data)
        break
    }
  }

  markAsEnded(data) {
    if (this.hasStatusTarget) this.statusTarget.innerText = "Đã kết thúc"
    if (this.hasBidFormTarget) this.bidFormTarget.remove()
    if (this.hasBuyNowBoxTarget) this.buyNowBoxTarget.remove()

    this.showFlash(data?.has_winner === false
      ? "Phiên đấu giá đã kết thúc và không có người thắng."
      : "Phiên đấu giá đã kết thúc."
    )
  }

  updatePrice(price) {
    if (price === null || price === undefined) return
    const formatted = this.formatNumber(price) + " ₫"
    this.currentPriceTargets.forEach(el => {
      el.innerText = formatted
      this.flashElement(el)
    })
  }

  updateBidCount(count) {
    if (count === undefined || count === null) return
    this.bidCountTargets.forEach(el => { el.innerText = count })
  }

  updateMinNextBid(minBid) {
    if (minBid === null || minBid === undefined) return
    const formatted = this.formatNumber(minBid)
    this.minNextBidTargets.forEach(el => { el.innerText = formatted + " ₫" })
    this.minNextBidHintTargets.forEach(el => { el.innerText = formatted })

    // Cập nhật placeholder input hiển thị
    if (this.hasAmountTarget) {
      this.amountTarget.placeholder = formatted
    }
  }

  prependBid(bid) {
    if (!this.hasBidsTarget) return

    const emptyRow = this.bidsTarget.querySelector("[data-empty-row]")
    if (emptyRow) emptyRow.remove()

    const tr = document.createElement("tr")
    tr.innerHTML = `
      <td class="text-truncate" style="max-width:220px;">${this.escapeHtml(bid.user_name)}</td>
      <td class="fw-semibold">${this.formatNumber(bid.amount)} ₫</td>
      <td class="text-end text-muted">${this.escapeHtml(bid.created_at)}</td>
    `

    tr.style.transition = "background 1.2s ease"
    tr.style.background = "#e7f3ff"
    this.bidsTarget.prepend(tr)

    requestAnimationFrame(() => {
      requestAnimationFrame(() => { tr.style.background = "" })
    })

    const rows = this.bidsTarget.querySelectorAll("tr")
    if (rows.length > 10) rows[rows.length - 1].remove()
  }

  markAsSold(_data) {
    if (this.hasStatusTarget) this.statusTarget.innerText = "Đã bán"
    if (this.hasBidFormTarget) this.bidFormTarget.remove()
    if (this.hasBuyNowBoxTarget) this.buyNowBoxTarget.remove()
  }

  // ── Flash helpers ── //
  showFlash(message, type = "error") {
    if (!this.hasFlashTarget) return
    this.flashTarget.classList.remove("hidden", "d-none")
    if (type === "success") {
      this.flashTarget.style.cssText = "border-color:#badbcc;background:#d1e7dd;color:#0a3622;"
    } else {
      this.flashTarget.style.cssText = "border-color:#f5c2c7;background:#f8d7da;color:#58151c;"
    }
    this.flashTarget.innerText = message
  }

  hideFlash() {
    if (!this.hasFlashTarget) return
    this.flashTarget.classList.add("hidden")
    this.flashTarget.innerText = ""
  }

  // ── Helpers ── //
  formatNumber(n) {
    if (n === null || n === undefined) return ""
    return Number(n).toLocaleString("vi-VN")
  }

  escapeHtml(str) {
    if (!str) return ""
    return String(str)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;")
      .replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }

  flashElement(el) {
    el.style.transition = "color 0.3s ease"
    el.style.color = "#0d6efd"
    setTimeout(() => { el.style.color = "" }, 800)
  }
}
