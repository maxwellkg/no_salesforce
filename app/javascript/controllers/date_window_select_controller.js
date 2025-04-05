import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['selector', 'customOptions']

  update() {
    const selectorValue = this.selectorTarget.value;

    if (selectorValue === 'c') {
      this.customOptionsTarget.classList.remove('hidden');
    } else {
      this.customOptionsTarget.classList.add('hidden');
    }
  }
}
