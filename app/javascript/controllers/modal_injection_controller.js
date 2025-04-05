import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // publish an event to let the modal controller know that the form is ready and that the modal
  // can be safely opened
  connect() {
    console.log('injecting!');
    const event = new CustomEvent("modalInjection:load", { bubbles: true, cancelable: true });
    document.dispatchEvent(event);
  }
}