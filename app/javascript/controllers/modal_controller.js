import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['modal']
  connect() {
    console.log(this.element, "hi!")
  }

  close() {
    this.modalTarget.remove()
  }
}