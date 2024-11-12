import consumer from "./consumer"

console.log("Attempting to subscribe to WebhookUpdatesChannel");

consumer.subscriptions.create("WebhookUpdatesChannel", {
  connected() {
    console.log("Successfully connected to WebhookUpdatesChannel");
  },
  disconnected() {
    console.log("Disconnected from WebhookUpdatesChannel");
  },
  received(data) {
    console.log("Received data on WebhookUpdatesChannel:", data);
  }
});