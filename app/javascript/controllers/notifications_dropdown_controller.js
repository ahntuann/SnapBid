import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.outsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.outsideClick, true)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClick, true)
  }

  handleOutsideClick(e) {
    // nếu click nằm trong dropdown => bỏ qua
    if (this.element.contains(e.target)) return

    // nếu menu đang mở => đóng
    if (this.menuTarget.classList.contains("show")) {
      const btn = this.buttonTarget
      const dd = window.bootstrap?.Dropdown?.getOrCreateInstance(btn)
      dd?.hide()
    }
  }
}
