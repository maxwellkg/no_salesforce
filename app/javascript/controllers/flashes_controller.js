import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flashes"
export default class extends Controller {

  hideMessage() {
    this.element.classList.remove("opacity-100")
    this.element.classList.add("opacity-0")
    setTimeout(() => this.element.remove(), 1_000)
  }

  connect() {
    setTimeout(() => this.hideMessage(), 10_000)
  }

}
