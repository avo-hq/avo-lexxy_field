import { Controller } from "@hotwired/stimulus"

// Wires Avo's media library into the Lexxy editor: the server renders a hidden
// link to the library, this controller moves it into Lexxy's toolbar, and Avo's
// media-library controller calls `insertAttachments` back once items are picked.
export default class extends Controller {
  static targets = ["mediaLibraryButton"]

  connect() {
    this.mountButton = this.#mountButton.bind(this)
    // Lexxy builds its toolbar when the editor boots, which may land before or
    // after this controller connects — cover both.
    this.element.addEventListener("lexxy:initialize", this.mountButton)
    this.#mountButton()
  }

  disconnect() {
    this.element.removeEventListener("lexxy:initialize", this.mountButton)
  }

  // Invoked by Avo's media-library controller.
  insertAttachments(attachments) {
    const html = attachments.map((attachment) => this.#htmlFor(attachment)).join("")

    if (html) this.#editor?.contents.insertHtml(html)
  }

  get #editor() {
    return this.element.querySelector("lexxy-editor")
  }

  #mountButton() {
    if (!this.hasMediaLibraryButtonTarget) return

    const toolbar = this.element.querySelector("lexxy-toolbar")
    const uploadButton = toolbar?.querySelector("[name='file'], [name='image']")
    if (!uploadButton) return

    uploadButton.insertAdjacentElement("afterend", this.mediaLibraryButtonTarget)
    this.mediaLibraryButtonTarget.removeAttribute("hidden")
  }

  #htmlFor({ blob, path }) {
    // An sgid (Action Text serializes one onto the blob since Rails 8.1) attaches
    // the blob itself. Without one, only images survive the save — as a remote
    // image — so anything else comes in as a link rather than silently vanishing.
    const element = blob.attachable_sgid || blob.content_type?.startsWith("image/")
      ? this.#attachmentElement(blob, path)
      : this.#linkElement(blob, path)

    return element.outerHTML
  }

  #attachmentElement(blob, path) {
    const attachment = document.createElement("action-text-attachment")

    if (blob.attachable_sgid) attachment.setAttribute("sgid", blob.attachable_sgid)
    attachment.setAttribute("url", path)
    attachment.setAttribute("content-type", blob.content_type)
    attachment.setAttribute("filename", blob.filename)
    attachment.setAttribute("filesize", blob.byte_size)
    attachment.setAttribute("alt", blob.metadata?.alt || blob.filename)
    if (blob.metadata?.width) attachment.setAttribute("width", blob.metadata.width)
    if (blob.metadata?.height) attachment.setAttribute("height", blob.metadata.height)

    return attachment
  }

  // Action Text has no remote-file equivalent of a remote image, so a
  // non-image without an sgid would be dropped on save. It comes in as a
  // plain link instead, like the markdown field does.
  #linkElement(blob, path) {
    const link = document.createElement("a")
    link.setAttribute("href", path)
    link.textContent = blob.filename

    return link
  }
}
