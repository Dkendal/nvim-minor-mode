;; Everything related to key mapping

(local nvim (require :minor-mode.nvim))
(local {: quote-expr : rtc} (require :minor-mode.strings))

(local M {})

(macro get-module-name [ast]
  "
  Return the name of the module, as it would be required.

  For example if the current file is fnl/foo/bar/.fnl the return value is 'foo.bar'

  The parameter [ast] is required to extract the filename from the call site.
  "
  (-> (getmetatable ast) (. :filename) (: :match "fnl/(.*).fnl")
      (: :gsub "/" ".")))

;; TODO replace with a function to trigger callback and trace calls
(set M.callbacks {})

(fn __index [tbl lhs]
  "Handle missing function handlers for keymaps"
  (local stack (debug.traceback))
  (error (.. "No function handler was defined for the key binding "
             (quote-expr lhs) stack)))

(setmetatable M.callbacks {: __index})

(local __module (get-module-name {}))

(fn M.bmap [mode lhs rhs ?opts]
  "
  Define a new buffer local map
  rhs may be a vim expression as a string, or a function callback.
  "
  (var rhs_ rhs)
  (when (= (type rhs) :function)
    (local key (rtc lhs))
    ;; TODO maybe this should be nested under the mode name?
    (tset M.callbacks key rhs)
    (var lua-expr (.. "require(" (quote-expr __module) ").callbacks["
                      (quote-expr key) "]()"))
    (set rhs_ (.. "<cmd>lua " lua-expr :<cr>)))
  (nvim.buf_set_keymap 0 mode lhs rhs_ (or ?opts {})))

M

