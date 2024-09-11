import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  // auto-open modal on connect
  connect() {
    console.log("modal#connect")
    this.modal = new bootstrap.Modal(this.element)
    this.modal.show()
    this.element.addEventListener('hidden.bs.modal', event => {
      console.log("modal closed")
      this.element.parentElement.removeAttribute('src')
      this.element.remove()
    })
  }

  disconnect() {
    console.log("modal#disconnect")
  }

  close() {
    console.log("modal#close")
    this.modal.hide()
  }

  // catch turbo:submit-end via action
  handleSubmit = (event) => {
    console.log("modal#handleSubmit")
    // close modal if form submission is successful
    if (event.detail.success) {
      console.log("modal#handleSubmit event successful")
    }
    this.close()
  }

}
