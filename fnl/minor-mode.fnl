(set debug.traceback fennel.traceback)

(local api vim.api)
(local ex vim.cmd)
(local luv vim.loop)
(local pack table.pack)

;; TODO move file
(fn pack [...]
  "Lua 5.2 table pack"
  (values [...] (select "#" ...)))

(local nvim {})
(setmetatable nvim {:__index #(. vim.api (.. :nvim_ $2))})

(local M {})

(local keymaps {})
(local minor-modes-enabled {})
(local counter {:n -1})

(setmetatable counter {:__call (fn [self]
                                 (set self.n (+ self 1))
                                 self.n)})

;; TODO move to a different file
(fn trace [func]
  "Add a stacktrace to the function on error"
  (fn [...]
    (local args [...])

    (fn wrapped-func []
      (func (unpack args)))

    (match [(xpcall wrapped-func debug.traceback)]
      [false err] (error err)
      [true value] value)))

;; TODO replace with a function to trigger callbag and trace calls
(set M.callbacks {})

(fn M.enabled-list []
  (icollect [mode-name bit-status (pairs minor-modes-enabled)]
    (when (= bit-status 1)
      mode-name)))

(fn rtc [code]
  "Replace termcodes"
  (nvim.replace_termcodes code true true true))

(fn quote-expr [expr]
  "Surround expr with double quotes, and escape any double quotes."
  (.. "\"" (string.gsub expr "\"" "\\\"") "\""))

(fn bmap [mode lhs rhs ?opts]
  "
  Define a new buffer local map
  rhs may be a vim expression as a string, or a function callback.
  "
  (var rhs_ rhs)
  (when (= (type rhs) :function)
    (local key (rtc lhs))
    ;; TODO maybe this should be nested under the mode name?
    (tset M.callbacks key rhs)
    (var lua-expr (.. "require('minor-mode').callbacks[" (quote-expr key) "]()"))
    (set rhs_ (.. "<cmd>lua " lua-expr :<cr>)))
  (nvim.buf_set_keymap 0 mode lhs rhs_ (or ?opts {})))

(fn M.toggle [mode-name]
  ;; TODO remove
  (print (.. mode-name " " (tostring (not (. minor-modes-enabled mode-name)))))
  (if (. minor-modes-enabled mode-name)
      (M.disable mode-name)
      (M.enable mode-name)))

;; TODO rename to def-minor-mode
;; TODO autogenerate command-name
(fn M.define [mode-name command-name mapping]
  "Define a new minor mode"
  (local lua-expr
         (.. "require('minor-mode').toggle(" (quote-expr mode-name) ")"))
  (ex (.. "command! " command-name " :lua " lua-expr :<cr>))
  (tset minor-modes-enabled mode-name false)
  (tset keymaps mode-name mapping))

;; TODO replace add minor mode command
(fn M.enable [mode-name]
  "Activate minor mode"
  ;; TODO replace with toggle command
  (tset minor-modes-enabled mode-name true)
  (local keymap (. keymaps mode-name))
  ;; TODO restore previous keymap
  ;; (local local-keymap (nvim.buf_get_keymap 0 :n))
  (each [lhs rhs (pairs keymap)]
    (assert (-> lhs (type) (= :string)))
    (bmap :n lhs rhs)))

;; TODO restore previous bindings
;; (fn restore-map [lhs]
;;   (local original (. local-keymap lhs))
;;   (nvim.buf_del_keymap 0 :n lhs)
;;   (when (and original (= original.mode :n))
;;     (nvim.buf_set_keymap 0 :n lhs original.rhs
;;                          {:expr (= original.expr :1)
;;                           :silent (= original.silent :1)
;;                           :nowait (= original.nowait :1)})))

(fn M.disable [mode-name]
  "Disable minor-mode keymap"
  (tset minor-modes-enabled mode-name false)
  (local keymap (. keymaps mode-name))
  (each [lhs _ (pairs keymap)]
    (nvim.buf_del_keymap 0 :n lhs)))

(fn M.setup []
  "Configure the plugin with global defaults")

(local traced-module {})
(setmetatable traced-module
              {:__index (fn [self key]
                          (match (. M key)
                            (where func (-> func (type) (= :function))) (trace func)
                            value value))})

traced-module

