import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ['select'];

  static values = {
    url: String,
    dimension: String
  }

  initialize() {
    this.changeListener = this.update.bind(this);
  }

  connect() {
    // initialize the tom select
    this.tomSelect = new TomSelect(this.selectTarget, { sortField: [{field: '$order'},{field: '$score'}] });

    // the tom select will actually create a new input section that is shown to the user
    // and this is the one that we'll want to look for changes in
    const id = `${this.dimensionValue}-ts-control`;
    document.getElementById(id).addEventListener('input', this.changeListener);
  }

  disconnect() {
    const id = `${this.dimensionValue}-ts-control`;
    const el = document.getElementById(id);

    if (el) {
      el.removeEventListener('input', this.changeListener);
    }
  }

  getUpdatedOptions(search_term) {
    let url = `${this.urlValue}&target=${this.dimensionValue}&search_term=${search_term}`;

    for (let i = 0; i < this.tomSelect.items.length; i++) {
      url += `&existing[]=${this.tomSelect.items[i]}`;
    }

    return get(url, {
      responseKind: 'turbo_stream'
    });
  }

  async update(event) {
    // only update when the user has provided two or more characters
    const id = `${this.dimensionValue}-ts-control`;
    const search_term = document.getElementById(id).value;

    if (search_term.length > 1) {
      const response = await this.getUpdatedOptions(search_term);

      // what we really need to do is wait for the turbo_stream to finish updating
      // but that isn't straightforward, so use this workaround for the time being
      if (response.ok) {
        // reinitialize a new Tom Select
        this.tomSelect.sync();
        this.tomSelect.refreshOptions(true);
      } else {
        console.log(response);
      }
    }
  }
}