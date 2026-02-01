import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    endAt: String
  };

  static targets = ["label"];

  connect() {
    this.tick = this.tick.bind(this);

    // Nếu không có ends_at -> không chạy
    if (!this.endAtValue) return;

    this.endTime = new Date(this.endAtValue);
    if (isNaN(this.endTime.getTime())) return;

    this.tick();
    this.timer = setInterval(this.tick, 1000);
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer);
  }

  tick() {
    const now = new Date();
    const diffMs = this.endTime - now;

    if (diffMs <= 0) {
      this.labelTarget.textContent = "Đã kết thúc";
      this.element.classList.add("text-muted");
      if (this.timer) clearInterval(this.timer);
      return;
    }

    const totalSeconds = Math.floor(diffMs / 1000);
    const days = Math.floor(totalSeconds / 86400);
    const hours = Math.floor((totalSeconds % 86400) / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    // Format gọn: ưu tiên “Còn …”
    let text = "Còn ";
    if (days > 0) {
      text += `${days}n ${hours}g`;
    } else if (hours > 0) {
      text += `${hours}g ${minutes}p`;
    } else {
      text += `${minutes}p ${seconds}s`;
    }

    this.labelTarget.textContent = text;

    // highlight khi < 1 giờ
    if (totalSeconds <= 3600) {
      this.element.classList.add("text-danger");
    }
  }
}
