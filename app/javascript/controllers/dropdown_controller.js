import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this._onDocClick = this.onDocClick.bind(this)
    document.addEventListener("click", this._onDocClick)

    this._beforeCache = () => this.close()
    document.addEventListener("turbo:before-cache", this._beforeCache)
  }

  disconnect() {
    document.removeEventListener("click", this._onDocClick)
    document.removeEventListener("turbo:before-cache", this._beforeCache)
  }

  toggle(e) {
    e.preventDefault()
    e.stopPropagation()
    this.menuTarget.classList.toggle("show")
  }

  close() {
    if (this.hasMenuTarget) this.menuTarget.classList.remove("show")
  }

  onDocClick(e) {
    if (!this.element.contains(e.target)) this.close()
  }
}
