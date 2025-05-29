import { Controller } from "@hotwired/stimulus"
import Tagify from "@yaireo/tagify"

// Connects to data-controller="tagging"
export default class extends Controller {
  static values = { options: Array }

  connect() {
    new Tagify(this.element, {
      whitelist: this.optionsValue,
      dropdown: {
        maxItems: 7,
        closeOnSelect: false,
        highlightFirst: true
      }
    })
  }
}
