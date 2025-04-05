import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Connects to data-controller="sal-modes"
export default class extends Controller {
  static values = {
    url: String
  }

  changeMode() {
    let mode = document.querySelector('select[name="mode"]').value;
    let url = `${this.urlValue}?mode=${mode}`

    return get(url, { responseKind: 'turbo_stream' });
  }

}
