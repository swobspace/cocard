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
    // overcome morph problems
    this.element.setAttribute("data-action",
                              "turbo:morph-element->datatables#reconnect"
                             )
    let _this = this
    let dtOptions = {}
    this.compileOptions(dtOptions)

    const table = $(this.element.querySelector('table'))
    console.log(table[0].id)
    // prepare options, optional add remote processing (not yet implemented)
    let dtable = $(table).DataTable(dtOptions)

    // catch column visibility change
    dtable.on('column-visibility.dt', function (e, settings, column, state) {
      // console.log(
      //   'Column ' + column + ' has changed to ' + (state ? 'visible' : 'hidden')
      // )
      if (state) {
        // console.log(e.target.querySelector('tfoot th[data-dt-column="' + column + '"]'))
        let th = e.target.querySelector('tfoot th[data-dt-column="' + column + '"]')
        let sf = th.querySelector('input')
        if (!sf) {
          th.insertAdjacentHTML('afterbegin', _this.searchField(column, ''))
        }
      }
    })


    if (!this.simpleValue) {
      this.setInputFields(dtable.state())
    }

    // process search input
    dtable.columns().eq(0).each((colIdx) => {
      $('input[name=idx'+colIdx+']').on( 'keyup change', function() {
	dtable.column(colIdx).search(this.value).draw()
      })
    })
  } // connect

  disconnect() {
  }

  // search fields for each column
  setInputFields(state) {
    // console.log(dtable.tables(0).columns)
    this.element.querySelectorAll("table tfoot th:not([class='nosearch'])")
        .forEach((th, idx) => {
          let col = th.getAttribute("data-dt-column")
          th.insertAdjacentHTML('afterbegin', this.searchField(col, state.columns[col].search.search))
        })
  }

  // single search input field
  searchField(idx, text) {
    return `<input type="text" placeholder="search" name="idx${idx}" value="${text}"/>`
  }

  // datatables options
  compileOptions(options) {
    // common options
    options.pagingType = "full_numbers"
    options.responsive = true
    options.stateSave = true
    options.stateDuration = 60 * 60 * 24
    // save state but don't save search filter
    options.stateSaveParams = function(settings, data) {
                                 data.search.search = '';
                               }
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
      buttons: [
                 { "text": 'Reset',
                    "action": function(e, dt, node, config) {
                                dt.state.clear();
                                window.location.reload();
                              }},
                 { "extend": 'csv',
	           "exportOptions": { "columns": ':visible',
                                      "search": ':applied' } },
                 { "extend": 'excel',
	           "exportOptions": { "columns": ':visible',
                                      "search": ':applied' } },
                 { "extend": 'pdf',
	           "orientation": 'landscape',
	           "pageSize": 'A4',
	           "exportOptions": { "columns": ':visible',
	                              "search": ':applied' } },
                 { "extend": 'print'},
                 { "extend": 'colvis', "columns": ':gt(0)' }
               ]
    }
  }

  remoteOptions(options) {
    options.searchDelay = 400
    options.processing = true
    options.serverSide = true
    options.ajax = { "url": this.urlValue, "type": "POST" }
  }

  // fix morph problems
  reconnect() {
    this.disconnect()
    this.connect()
  }

  colvis(e, settings, column, state) {
    console.log("ColVis")
    console.log(
      'Column ' + column + ' has changed to ' + (state ? 'visible' : 'hidden')
    )
  }
} // Controller
