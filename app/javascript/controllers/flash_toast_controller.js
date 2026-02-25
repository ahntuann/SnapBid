import { Controller } from "@hotwired/stimulus"

// Kết nối controller này vào phần tử chứa tất cả toast
// Các toast con sẽ tự động show và tự dismiss sau 4 giây
export default class extends Controller {
   connect() {
      this.element.querySelectorAll(".toast").forEach(el => {
         const toast = new bootstrap.Toast(el, { delay: 3000 })
         toast.show()
      })

      // Xóa toast khỏi DOM trước khi Turbo lưu cache trang
      // Ngăn toast cũ xuất hiện lại khi quay lại trang bằng nút Back
      this.beforeCacheHandler = () => {
         this.element.innerHTML = ""
      }
      document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
   }

   disconnect() {
      document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
   }
}
