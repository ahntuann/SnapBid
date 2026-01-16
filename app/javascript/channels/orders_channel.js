import consumer from "./consumer"

console.log("[OrdersChannel] subscribing...")

consumer.subscriptions.create({ channel: "OrdersChannel" }, {
  connected() { console.log("[OrdersChannel] connected") },
  disconnected() { console.log("[OrdersChannel] disconnected") },
  received(data) {
    console.log("[OrdersChannel] received", data)
    window.dispatchEvent(new CustomEvent("orders:received", { detail: data }))
  }
})
