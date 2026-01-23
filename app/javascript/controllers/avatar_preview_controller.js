import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "img", "placeholder", "filename"]

  preview() {
    const file = this.inputTarget.files?.[0]
    if (!file || !file.type.startsWith("image/")) return

    const url = URL.createObjectURL(file)

    this.imgTarget.src = url
    this.imgTarget.style.display = ""
    this.placeholderTarget.style.display = "none"
    this.filenameTarget.textContent = file.name
  }
}
