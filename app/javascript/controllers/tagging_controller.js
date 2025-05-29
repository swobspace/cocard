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
        enabled: 0,
        position: "text",
        closeOnSelect: false,
        highlightFirst: true
      }
    })
    console.log(this.optionsValue)
  }
}
