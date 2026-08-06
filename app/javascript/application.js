// Registers the <lexxy-editor> custom elements on import.
import * as Lexxy from "@37signals/lexxy"
import "./controllers"

// Avo's layout never loads the host app's JS bundle, so this module is the only
// handle a host app has on the editor. Lexxy defines its elements on a timer to
// leave room for global configuration, and that timer fires as soon as this
// script's task ends — so `Lexxy.configure` has to be called from here, not
// "whenever". An inline script in avo/partials/head parses before this deferred
// bundle runs, so a listener registered there gets called back in time.
window.Lexxy = Lexxy
document.dispatchEvent(new CustomEvent("avo:lexxy:configure", { detail: Lexxy }))
