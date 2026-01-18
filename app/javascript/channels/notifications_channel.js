import consumer from "./consumer"

console.log("[NotificationsChannel] subscribing...")

consumer.subscriptions.create({ channel: "NotificationsChannel" }, {
  connected() { console.log("[NotificationsChannel] connected") },
  disconnected() { console.log("[NotificationsChannel] disconnected") },
  received(data) {
    console.log("[NotificationsChannel] received", data)
    window.dispatchEvent(new CustomEvent("notifications:received", { detail: data }))
  }
})
