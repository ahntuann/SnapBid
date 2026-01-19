import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["main"]

  pick(event) {
    const btn = event.currentTarget
    const url = btn.dataset.galleryUrl
    if (!url) return

    this.mainTarget.src = url

    this.element.querySelectorAll(".gallery-thumb").forEach((el) => el.classList.remove("active"))
    btn.classList.add("active")
  }
}
