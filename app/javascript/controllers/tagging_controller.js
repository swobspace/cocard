import { Controller } from "@hotwired/stimulus"
import Tagify from "@yaireo/tagify"

// Connects to data-controller="tagging"
export default class extends Controller {
  static values = { options: Array }

  connect() {
    // avoid problems with forms and 422 responses: replace refresh=morph
    const turborefresh = document.querySelector('head meta[name="turbo-refresh-method"]')
    if (turborefresh) {
      turborefresh.setAttribute("content", "replace")
    }

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
