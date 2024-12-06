// app/javascript/controllers/toggle_fields_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-fields"
export default class extends Controller {
  static targets = ["hidden", "input"]

  connect() {
    this.inputTarget.addEventListener("change", this.toggle.bind(this))
    this.inputTarget.addEventListener("keyup", this.toggle.bind(this))
    this.toggle()
  }

  disconnect() {
    this.inputTarget.removeEventListener("change", this.toggle.bind(this))
    this.inputTarget.removeEventListener("keyup", this.toggle.bind(this))
  }

  toggle() {
    this.hiddenTargets.forEach((target) => {
      const targetValue = target.dataset.value ? target.dataset.value : null
      const greaterThanValue = target.dataset.greaterThan ? parseFloat(target.dataset.greaterThan) : null
      const lessThanValue = target.dataset.lessThan ? parseFloat(target.dataset.lessThan) : null
      // console.log(this.value, targetValue, greaterThanValue, lessThanValue);

      let shouldShow = true

      if (targetValue !== null && this.value !== targetValue) { shouldShow = false }
      if (greaterThanValue !== null && this.value < greaterThanValue) { shouldShow = false }
      if (lessThanValue !== null && this.value > lessThanValue) { shouldShow = false }

      if (shouldShow) {
        target.classList.remove("d-none")
      } else {
        target.classList.add("d-none")
      }
    })
  }

  get value() {
    switch (this.inputTarget.type) {
      case "checkbox":
        return this.inputTarget.checked ? "true" : "false"
      case "number":
        return this.inputTarget.value ? parseFloat(this.inputTarget.value) : null
      default:
        return this.inputTarget.value
    }
  }
}
