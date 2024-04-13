import { Controller } from "@hotwired/stimulus"

import '../src/datatables-bs5'

export default class extends Controller {
  static values = {
    simple: Boolean,
    url: String
  }

  initialize() {
  }

  connect() {
    let dtOptions = {}
    this.compileOptions(dtOptions)
    if (!this.simpleValue) {
      this.setInputFields()
    }
    const table = $(this.element.querySelector('table'))

    // prepare options, optional add remote processing (not yet implemented)
    let dtable = $(table).DataTable(dtOptions)

    // process search input
    dtable.columns().eq(0).each((colIdx) => {
      $('input[name=idx'+colIdx+']').on( 'keyup change', function() {
	dtable.column(colIdx).search(this.value).draw()
      })
    })
  } // connect

  // search fields for each column
  setInputFields() {
    this.element.querySelectorAll("table tfoot th:not([class='nosearch'])")
        .forEach((th, idx) => {
          th.insertAdjacentHTML('afterbegin', this.searchField(idx))
        })
  }

  // single search input field
  searchField(idx) {
    return `<input type="text" placeholder="search" name="idx${idx}" />`
  }

  // datatables options
  compileOptions(options) {
    // common options
    options.pagingType = "full_numbers"
    options.stateSave = false
    options.lengthMenu = [ [10, 25, 100, 250, 1000], [10, 25, 100, 250, 1000] ]
    options.columnDefs = [ { "targets": "nosort", "orderable": false },
                           { "targets": "notvisible", "visible": false },
                           { "targets": "actions", "className": "actions" } ]
    // with or without buttons
    if (this.simpleValue) {
      this.simpleOptions(options)
    } else {
      this.buttonOptions(options)
    }

    // remote fetch via ajax or plain html data
    if (this.hasUrlValue) {
      this.remoteOptions(options)
    }
  }

  simpleOptions(options) {
    options.dom =  "<'row'<'col-sm-12'tr>>" +
                   "<'row'<'col pt-2'l><'col'i><'col'p>>"
    options.pagingType = "numbers"
  }


  buttonOptions(options) {
    options.dom = "<'row mt-2 justify-content-between'<'col-md-auto me-auto'l><'col-md-auto'B>>" +
                    "<'row mt-2 justify-content-md-center'<'col-sm-12'tr>>" +
                    "<'row mt-2 justify-content-between'<'col-md-auto me-auto'i><'col-md-auto ms-auto'p>>"
    options.buttons = {
      dom: {
        button: {
          tag: 'button',
          className: 'btn btn-outline-secondary btn-sm'
        }
      },
      buttons: [ { "extend": 'excel',
	           "exportOptions": { "search": ':applied' } },
                 { "extend": 'pdf',
	           "orientation": 'landscape',
	           "pageSize": 'A4',
	           "exportOptions": { "columns": ':visible',
	                              "search": ':applied' } },
                 { "extend": 'print'},
                 { "extend": 'colvis', "columns": ':gt(0)' } ]
    }
  }

  remoteOptions(options) {
    options.searchDelay = 400
    options.processing = true
    options.serverSide = true
    options.ajax = { "url": this.urlValue, "type": "POST" }
  }
} // Controller
