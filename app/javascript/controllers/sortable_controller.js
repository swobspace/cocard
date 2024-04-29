import { Controller } from "@hotwired/stimulus"
import { Sortable } from '@shopify/draggable';

export default class extends Controller {
  static targets = ['item']
  static values = {
    handle: String
  }

  connect() {
    let _this = this
    if (this.hasItemTarget) {
      this.itemTargets.forEach(item => {
        item.setAttribute('style', 'z-index: 1000;')
        item.classList.add('draggable-source')
      })

      const sortable = new Sortable(this.element, {
        draggable: '.draggable-source',
        handle: this.handleValue,
        distance: 15,
        mirror: {
          constrainDimensions: true
        }
      })
      sortable.on('sortable:start', function(event) {
        let item = event.dragEvent.source
        item.setAttribute('style', 'z-index: 1000; background-color: #FFFFAB;')
      })
      sortable.on('sortable:stop', function(event) {
        // avoid update if no changes detected
        if (event.oldIndex == event.newIndex) {
          return
        }
        let item = event.dragEvent.source
        // needs something like id="<%= dom_id item %>"
        let item_id = item.id.substr(item.id.lastIndexOf("_")+1)
        let item_type = item.id.substr(0, item.id.lastIndexOf("_"))
        let url = item.getAttribute('data-url')
        let data = {[item_type]: { position: (event.data.newIndex + 1) }}
        let token = document.head.querySelector('meta[name="csrf-token"]').getAttribute('content')
        fetch(url, {
          method: 'PUT',
          credentials: 'same-origin',
          headers: {
            "X-CSRF-Token": token,
            "Accept": "text/vnd.turbo-stream.html",
            "Content-type": "application/json"
          },
          body: JSON.stringify(data)
        })
        .then(r => r.text())
        .then(html => Turbo.renderStreamMessage(html))
      })
    }
  }

}
