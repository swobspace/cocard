// app/javascript/controllers/show_secret_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { secret: String }

  connect() {
    this.originalValue = this.contentTarget.innerHTML
    this.secretDisplayed = false
  }

  toggleSecret(event) {
    event.preventDefault()
    if (this.secretDisplay) {
      this.contentTarget.innerHTML = this.originalValue
    } else {
      this.contentTarget.innerHTML = this.secretValue
    }
    this.secretDisplay = !this.secretDisplay
    this.iconTarget.classList.toggle("fa-eye-slash")
    this.iconTarget.classList.toggle("fa-eye")
  }
}
