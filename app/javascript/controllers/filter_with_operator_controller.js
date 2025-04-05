import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['selector', 'outerWrapper', 'firstValueWrapper', 'firstValue', 'secondValueWrapper', 'secondValue']

  update() {
    const selectorValue = this.selectorTarget.value;

    this.firstValueTarget.value = "";
    this.secondValueTarget.value = "";

    if (selectorValue) {
      this.outerWrapperTarget.classList.remove('hidden');
      this.firstValueWrapperTarget.classList.remove('hidden');
    } else {
      this.firstValueWrapperTarget.classList.add('hidden');
      this.outerWrapperTarget.classList.add('hidden');
    }

    if (selectorValue === 'between') {
      this.secondValueWrapperTarget.classList.remove('hidden');
    } else {
      this.secondValueWrapperTarget.classList.add('hidden');
    }
  }  
}