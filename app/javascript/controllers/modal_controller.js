import { Controller } from "@hotwired/stimulus"
import * as bootstrap from 'bootstrap'

// Call the controller from sharedModal in the application layout

export default class extends Controller {
  static values = {
    modalId : String
  }

  /* open modal via link. i.e.

     <%= link_to 'Add Mymodel',
                 new_mymodel_path,
                 class: "btn btn-secondary",
                 data: {
                   controller: :modal,
                   'modal-modal-id-value': 'sharedModal',
                   action: 'click->modal#open',
                   'turbo-frame': "modal-body"
                 } %>
     The modal with id sharedModal is always present vi application layout. The
     response from the link must contain a turbo_frame_tag 'modal-body'
  */

  open() {
    // fetch modal id
    const modal_id =  this.modalIdValue
    let modalElement = document.getElementById(modal_id)

    // initialize modal and open it
    let myModal = new bootstrap.Modal(modalElement)
    myModal.show()
  }


  close() {
      // close modal element
      let modalElement = document.getElementById(this.element.id)

      // fetch existing modal instance and close it
      let myModal = bootstrap.Modal.getInstance(modalElement)
      myModal.hide()
  }

  /* close the modal form only if submission is successful
     catch turbo:submit-end via action 
     (don't include the controller here, modal controller is always
      included via sharedModal)

     <%= form_for(@mymodel,
         data: { action: "turbo:submit-end->modal#handleSubmit" }) do |f| %>
   */

  handleSubmit = (event) => {
    // close modal if form submission is successful
    if (event.detail.success) {
      this.close()
    }
  }
}
