import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["currentPrice", "bids", "bidForm", "status", "flash"]
  static values  = { id: Number } // <<< BẮT BUỘC để dùng this.idValue

  connect() {
    const listingId = this.idValue
    console.log("[AC] connect listing", listingId)

    if (!listingId) {
      console.warn("[AC] Missing listingId (check data-listing-id-value)")
      return
    }

    this.subscription = consumer.subscriptions.create(
      { channel: "ListingsChannel", listing_id: listingId },
      {
        connected: () => console.log("[AC] connected", listingId),
        disconnected: () => console.log("[AC] disconnected", listingId),
        received: (data) => {
          console.log("[AC] received", data)
          this.handleMessage(data)
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) consumer.subscriptions.remove(this.subscription)
  }

  handleMessage(data) {
    switch (data.type) {
      case "new_bid":
        this.updatePrice(data.current_price)
        this.prependBid(data.bid)
        break
      case "sold":
        this.markAsSold(data)
        break
      case "flash":
        this.showFlash(data.message)
        break
      default:
        // ignore
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

  markAsSold() {
    if (this.hasStatusTarget) this.statusTarget.innerText = "Đã bán"
    if (this.hasBidFormTarget) this.bidFormTarget.remove()
  }

  showFlash(message) {
    if (!this.hasFlashTarget) return
    this.flashTarget.innerText = message
    this.flashTarget.classList.remove("hidden")
  }
}
