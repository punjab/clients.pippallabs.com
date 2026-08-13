import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    // Close before Turbo snapshots the page, otherwise a restoration visit
    // (Back button) re-renders the dialog open but outside the top layer.
    this.beforeCache = () => this.dialogTarget.open && this.dialogTarget.close()
    document.addEventListener("turbo:before-cache", this.beforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.beforeCache)
  }

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  closeBackdrop(event) {
    // Content sits in a padded inner wrapper, so the dialog element itself is
    // only hit by clicks on the ::backdrop.
    if (event.target === this.dialogTarget) this.dialogTarget.close()
  }
}
