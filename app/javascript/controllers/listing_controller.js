import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["currentPrice", "bids", "bidForm", "status", "flash", "amount", "confirmBuyNow", "buyNowBox"]
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

  // --- UI warning khi gõ ---
  checkBuyNowThreshold() {
    if (!this.buyNowEnabledValue) return
    if (!this.hasAmountTarget) return

    const amount = parseFloat(this.amountTarget.value || "0")
    const buyNow = parseFloat(this.buyNowPriceValue || "0")
    if (!buyNow || amount < buyNow) {
      this.hideFlash()
      return
    }

    this.showFlash(`Giá bạn nhập (${amount}) ≥ giá mua ngay (${buyNow}). Nếu bấm "Đặt giá", hệ thống sẽ hỏi để MUA NGAY với giá ${buyNow}.`)
  }

  // --- chặn submit để hỏi confirm ---
  submitBid(event) {
    const form = event.target

    // Nếu đây là lần submit "thật" sau khi đã confirm => cho chạy bình thường
    if (form.dataset.skipConfirm === "1") {
      form.dataset.skipConfirm = "0"
      return
    }

    if (!this.hasBuyNowEnabledValue || !this.buyNowEnabledValue) return
    if (!this.hasBuyNowPriceValue || !this.hasAmountTarget || !this.hasConfirmBuyNowTarget) return

    const amount = Number(this.amountTarget.value || 0)
    const buyNow = Number(this.buyNowPriceValue || 0)
    if (!amount || !buyNow) return

    if (amount >= buyNow) {
      event.preventDefault()

      const ok = window.confirm(
        `Giá bạn nhập (${amount}) ≥ giá mua ngay (${buyNow}).\n` +
        `Nếu tiếp tục, bạn sẽ MUA NGAY với giá ${buyNow}.\n\n` +
        `Bạn có muốn mua ngay không?`
      )

      if (!ok) {
        this.showFlash("Bạn đã huỷ mua ngay. Vui lòng nhập giá thấp hơn giá mua ngay.")
        return
      }

      // OK => set flag để backend xử lý mua ngay
      this.confirmBuyNowTarget.value = "1"

      // Tránh confirm lặp khi submit lại
      form.dataset.skipConfirm = "1"

      const submitter = form.querySelector('input[type="submit"],button[type="submit"]')

      // Quan trọng: submit sau khi handler hiện tại kết thúc
      setTimeout(() => {
        if (submitter) {
          form.requestSubmit(submitter)
        } else {
          form.requestSubmit()
        }
      }, 0)
    }
  }

  beforeBidSubmit(event) {
    return this.submitBid(event)
  }

  scheduleAuctionEnd() {
    if (!this.hasAuctionEndsAtValue) return
    if (!this.auctionEndsAtValue) return

    const endsAt = Date.parse(this.auctionEndsAtValue)
    if (Number.isNaN(endsAt)) return

    const delay = endsAt - Date.now()

    // Nếu đã quá giờ => update UI ngay
    if (delay <= 0) {
      this.markAsEndedUI()
      return
    }

    // Đến giờ thì tự đổi UI (không cần reload)
    this._endTimer = setTimeout(() => {
      this.markAsEndedUI()
    }, delay)
  }

markAsEndedUI() {
  // Tránh chạy lại nhiều lần
  if (this._alreadyEnded) return
  this._alreadyEnded = true

  if (this.hasStatusTarget) this.statusTarget.innerText = "Đã kết thúc"

  // Ẩn form bid
  if (this.hasBidFormTarget) this.bidFormTarget.remove()

  // Ẩn box mua ngay (nếu có)
  if (this.hasBuyNowBoxTarget) this.buyNowBoxTarget.remove()

  this.showFlash("Phiên đấu giá đã kết thúc.")
}


  // --- realtime handlers ---
  handleMessage(data) {
    switch (data.type) {
      case "new_bid":
        this.updatePrice(data.current_price)
        this.prependBid(data.bid)
        break
      case "sold":
        this.markAsSold(data)
        break
    }
  }

  updatePrice(price) {
    if (this.hasCurrentPriceTarget) this.currentPriceTarget.innerText = price
  }

  prependBid(bid) {
    if (!this.hasBidsTarget) return
    const li = document.createElement("li")
    li.innerText = `${bid.user_name}: ${bid.amount} - ${bid.created_at}`
    this.bidsTarget.prepend(li)
  }

  markAsSold(_data) {
    if (this.hasStatusTarget) this.statusTarget.innerText = "Đã bán"
    if (this.hasBidFormTarget) this.bidFormTarget.remove()
  }

  // --- flash helpers ---
  showFlash(message) {
    if (!this.hasFlashTarget) return
    this.flashTarget.classList.remove("hidden")
    this.flashTarget.style.borderColor = "#f5c2c7"
    this.flashTarget.style.background = "#f8d7da"
    this.flashTarget.innerText = message
  }

  hideFlash() {
    if (!this.hasFlashTarget) return
    this.flashTarget.classList.add("hidden")
    this.flashTarget.innerText = ""
  }
}
