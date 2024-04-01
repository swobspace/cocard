import { Controller } from "@hotwired/stimulus"
import TomSelect from 'tom-select/dist/js/tom-select.complete.js';

// Connects to data-controller="select"
export default class extends Controller {
  connect() {
    // set basic options
    let options = {
      create: false,
      allowEmptyOption: true,
      closeAfterSelect: true,
      sortField: {
        field: "text",
        direction: "asc"
      },
      plugins: ['clear_button']
    }
    // query url
    let url = this.element.dataset.tokens
    if (url) {
      options.valueField = 'id'
      options.labelField = 'name'
      options.searchField = 'name'
      options.load = function(query,callback) {
                      let search = url + '?q=' + encodeURIComponent(query)
		      fetch(search)
			.then(response => response.json())
			.then(json => {
			  callback(json);
			}).catch(()=>{
			  callback()
			})
		     }
      // options.render = {
      //   option: function(data,escape) {
      //             return '<div>' + escape(data.name) + '</div>'
      //           },
      //   item: function(data,escape) {
      //             return '<div>' + escape(data.name) + '</div>'
      //           }
      // }
    }
    new TomSelect(this.element, options)
  }
}
