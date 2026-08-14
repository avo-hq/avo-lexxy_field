// Registers the <lexxy-editor> custom elements on import.
import * as Lexxy from "@37signals/lexxy"
import "./controllers"

// Other Avo gems bundle their own copy of Lexxy (avo-ai's chat composer does),
// and each copy registers the same custom elements on a timer with no
// already-defined guard — whichever timer fires second throws NotSupportedError
// and aborts the rest of its setup. Until Lexxy guards its defineElements,
// drop duplicate lexxy-* registrations instead: first copy wins, which is the
// registry's behavior for the elements anyway. Installed at module evaluation,
// so it's in place before any copy's registration timer fires, whatever order
// the bundles load in.
const define = CustomElementRegistry.prototype.define
CustomElementRegistry.prototype.define = function (name, ...rest) {
  if (name.startsWith("lexxy-") && this.get(name)) return

  define.call(this, name, ...rest)
}

// Avo's layout never loads the host app's JS bundle, so this module is the only
// handle a host app has on the editor. Lexxy defines its elements on a timer to
// leave room for global configuration, and that timer fires as soon as this
// script's task ends — so `Lexxy.configure` has to be called from here, not
// "whenever". An inline script in avo/partials/head parses before this deferred
// bundle runs, so a listener registered there gets called back in time.
window.Lexxy = Lexxy
document.dispatchEvent(new CustomEvent("avo:lexxy:configure", { detail: Lexxy }))
