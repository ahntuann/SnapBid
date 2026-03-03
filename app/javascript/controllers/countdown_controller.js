import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { endAt: String };

  // targets: days, hours, minutes, seconds (each has a "value" span)
  static targets = ["days", "hours", "minutes", "seconds", "label"];

  connect() {
    this.tick = this.tick.bind(this);
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
      this._setBlocks(0, 0, 0, 0);
      if (this.hasLabelTarget) this.labelTarget.textContent = "Đã kết thúc";
      this.element.classList.add("text-danger");
      if (this.timer) clearInterval(this.timer);
      return;
    }

    const totalSeconds = Math.floor(diffMs / 1000);
    const days = Math.floor(totalSeconds / 86400);
    const hours = Math.floor((totalSeconds % 86400) / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    this._setBlocks(days, hours, minutes, seconds);

    // Đổi màu đỏ khi < 60 phút
    if (totalSeconds <= 3600) {
      this.element.classList.add("text-danger");
    } else {
      this.element.classList.remove("text-danger");
    }
  }

  _setBlocks(d, h, m, s) {
    if (this.hasDaysTarget) this.daysTarget.textContent = String(d).padStart(2, "0");
    if (this.hasHoursTarget) this.hoursTarget.textContent = String(h).padStart(2, "0");
    if (this.hasMinutesTarget) this.minutesTarget.textContent = String(m).padStart(2, "0");
    if (this.hasSecondsTarget) this.secondsTarget.textContent = String(s).padStart(2, "0");
  }
}
