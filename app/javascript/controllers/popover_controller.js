import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="popover"
export default class extends Controller {
  connect() {
    new bootstrap.Popover(this.element)
  }
}
