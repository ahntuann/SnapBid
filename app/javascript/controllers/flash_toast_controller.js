import { Controller } from "@hotwired/stimulus"

// Kết nối controller này vào phần tử chứa tất cả toast
// Các toast con sẽ tự động show và tự dismiss sau 4 giây
export default class extends Controller {
   connect() {
      this.element.querySelectorAll(".toast").forEach(el => {
         const toast = new bootstrap.Toast(el, { delay: 3000 })
         toast.show()
      })
   }
}
