import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "place"]

  connect() {
    this.refresh()
  }

  refresh() {
    const selected = this.element.querySelector("input[name='interview[format]']:checked")
    const format = selected ? selected.value : ""
    if (this.hasUrlTarget) this.urlTarget.required = format === "online"
    if (this.hasPlaceTarget) this.placeTarget.required = format === "onsite"
  }
}
