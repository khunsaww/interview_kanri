import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { items: Array }

  connect() {
    if (this.notificationPermission() === "granted") this.notify()
  }

  enable(event) {
    event.preventDefault()
    if (!("Notification" in window)) {
      this.showStatus("このブラウザは通知に対応していません。予定は一覧で確認できます。")
      return
    }

    Notification.requestPermission().then((permission) => {
      if (permission === "granted") {
        this.notify()
        this.showStatus("ブラウザ通知を有効にしました。")
      } else {
        this.showStatus("通知は許可されませんでした。予定は画面の一覧で確認できます。")
      }
    })
  }

  notify() {
    const seen = JSON.parse(window.sessionStorage.getItem("interview-reminders") || "[]")
    this.itemsValue.forEach((item) => {
      if (seen.includes(item.id)) return

      new Notification(item.title, { body: item.body })
      seen.push(item.id)
    })
    window.sessionStorage.setItem("interview-reminders", JSON.stringify(seen))
  }

  notificationPermission() {
    return "Notification" in window ? Notification.permission : "denied"
  }

  showStatus(message) {
    let status = this.element.querySelector("[data-reminder-status]")
    if (!status) {
      status = document.createElement("p")
      status.setAttribute("role", "status")
      status.dataset.reminderStatus = "true"
      this.element.appendChild(status)
    }
    status.textContent = message
  }
}
