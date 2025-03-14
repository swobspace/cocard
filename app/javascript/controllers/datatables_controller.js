import { Controller } from "@hotwired/stimulus"

import '../src/datatables-bs5'
import DataTable from 'datatables.net';


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

    const table = this.element.querySelector('table')
    // console.log(table)

    // initialize datatable
    let dtable = new DataTable(table, dtOptions)
    // console.log(dtable.page.info().serverSide)

    // catch column visibility change
    this.colvis_change_listener(dtable)

    if (!this.simpleValue) {
      // wait for init complete if server side processing
      // else call setInputFields directly
      if (dtable.page.info().serverSide == true) {
        dtable.on('init.dt', function() {
          _this.setInputFields(dtable)
          _this.process_search_input(dtable)
        })
      } else {
        this.setInputFields(dtable)
        this.process_search_input(dtable)
      }
    }

  } // connect

  disconnect() {
  }

  // search fields for each column
  setInputFields(dtable) {
    this.element.querySelectorAll("table tfoot th:not([class='nosearch'])")
        .forEach((th, idx) => {
          let col = th.getAttribute("data-dt-column")
          let text = ''
          let state = dtable.state();
          if (state) {
            text = state.columns[col].search.search
          }
          th.insertAdjacentHTML('afterbegin', this.searchField(col, text))
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
    options.lengthMenu = [10, 25, 100, 250, 1000, { label: 'Alle', value: -1}]
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
    this.languageOptions(options)
  }

  simpleOptions(options) {
    options.dom =  "<'row '<'col-sm-12'tr>>" +
                   "<'row mt-2 justify-content-between'<'col-md-auto me-auto mt-1'l><'col-md-auto me-auto mt-2'i><'col-md-auto ms-auto'p>>"
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
                 { "extend": 'colvis', "columns": ':gt(0)',
                   "text": "Sichbare Spalten" }
               ]
    }
  }

  remoteOptions(options) {
    //
    let csrf = document.head.querySelector('meta[name="csrf-token"]')
    let token = "not available"
    if (csrf != null) {
      token = csrf.getAttribute('content')
    }
    options.searchDelay = 400
    options.processing = true
    options.serverSide = true
    options.ajax = {
      'url': this.urlValue,
      'type': 'POST',
      'beforeSend': function(request) {
        request.setRequestHeader("X-CSRF-Token", token)
      }
    }
  }

  // fix morph problems
  reconnect() {
    this.disconnect()
    this.connect()
  }

  colvis_change_listener(dtable) {
    const search = this.createSearchWithDebounce(dtable)
    let _this = this
    dtable.on('column-visibility.dt', function (e, settings, column, state) {
      if (state) {
        let th = e.target.querySelector('tfoot th[data-dt-column="' + column + '"]:not(.nosearch)')
        if (th) {
	  let sf = th.querySelector('input')
	  if (!sf) {
	    th.insertAdjacentHTML('afterbegin', _this.searchField(column, ''))
	  }
        }
        $('input[name=idx'+column+']').on( 'keyup change', function() {
          search(column, this.value)
        })
      }
    })
  }

  process_search_input(dtable) {
    const search = this.createSearchWithDebounce(dtable)
    dtable.columns().eq(0).each((colIdx) => {
      $('input[name=idx'+colIdx+']').on( 'keyup change', function() {
	search(colIdx, this.value)
      })
    })
  }

  createSearchWithDebounce(dtable, delay = 400) {
    if (!dtable || !dtable.column || !dtable.column().search || !dtable.draw || !DataTable.util.debounce) {
      console.error("Invalid DataTable instance or missing debounce utility.");
      return null
    }
    let search;
    if (dtable.page.info().serverSide) {
      search = DataTable.util.debounce(function (col, val) {
	               dtable.column(col).search(val).draw()
                     }, delay)
    } else {
      search = function (col, val) {
	               dtable.column(col).search(val).draw()
                     }
    }
    return search
  }

  languageOptions(options) {
    options.language = {
      "emptyTable":      "Keine Daten in der Tabelle vorhanden",
      "info":            "_START_ bis _END_ von _TOTAL_ Einträgen",
      "infoEmpty":       "0 bis 0 von 0 Einträgen",
      "infoFiltered":    "(gefiltert von _MAX_ Einträgen)",
      "infoPostFix":     "",
      "thousands":   ".",
      "lengthMenu":      "_MENU_ Einträge anzeigen",
      "loadingRecords":  "Wird geladen...",
      "processing":      "Bitte warten...",
      "search":          "Suchen",
      "zeroRecords":     "Keine Einträge vorhanden.",
      "paginate": {
          "first":       "Erste",
          "previous":    "Zurück",
          "next":        "Nächste",
          "last":        "Letzte"
      },
      "aria": {
          "sortAscending":  ": aktivieren, um Spalte aufsteigend zu sortieren",
          "sortDescending": ": aktivieren, um Spalte absteigend zu sortieren"
      }
    }
  }

} // Controller
