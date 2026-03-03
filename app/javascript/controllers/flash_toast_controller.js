import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
   connect() {
      // Show all toasts present on connect
      this.showToasts()

      // Listen for new toasts added to this container
      this.observer = new MutationObserver(() => this.showToasts())
      this.observer.observe(this.element, { childList: true })

      // Handler for Turbo cache
      this.beforeCacheHandler = () => {
         this.element.innerHTML = ""
      }
      document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
   }

   disconnect() {
      if (this.observer) this.observer.disconnect()
      document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
   }

   showToasts() {
      this.element.querySelectorAll(".toast:not(.showing):not(.show)").forEach(el => {
         const toast = new bootstrap.Toast(el, { delay: 4000, autohide: true })
         toast.show()
      })
   }
}
