(set debug.traceback fennel.traceback)

(local nvim (require :minor-mode.nvim))
(local {: bmap} (require :minor-mode.map))
(local {: quote-expr : rtc} (require :minor-mode.strings))
(local {: trace-module} (require :minor-mode.trace))

(local api vim.api)
(local ex vim.cmd)
(local luv vim.loop)
(local pack table.pack)

;; TODO move file
(fn pack [...]
  "Lua 5.2 table pack"
  (values [...] (select "#" ...)))

(local M {})

(local keymaps {})
(local minor-modes-enabled {})

(fn M.enabled-list []
  (icollect [mode-name bit-status (pairs minor-modes-enabled)]
    (when (= bit-status 1)
      mode-name)))

(fn M.toggle [mode-name]
  "Toggle a minor mode, enable or disable will be called conditionaly"
  (if (. minor-modes-enabled mode-name)
      (M.disable mode-name)
      (M.enable mode-name))
  (print (.. mode-name " " (tostring (. minor-modes-enabled mode-name)))))

;; TODO rename to def-minor-mode
;; TODO autogenerate command-name
(fn M.define [mode-name command-name mapping]
  "Define a new minor mode"
  (local lua-expr (.. "require('minor-mode').toggle(" (quote-expr mode-name)
                      ")"))
  (ex (.. "command! " command-name " :lua " lua-expr :<cr>))
  (tset minor-modes-enabled mode-name false)
  (tset keymaps mode-name mapping))

;; TODO replace add minor mode command
(fn M.enable [mode-name]
  "Activate minor mode"
  (tset minor-modes-enabled mode-name true)
  (local keymap (. keymaps mode-name))
  ;; TODO restore previous keymap
  ;; (local local-keymap (nvim.buf_get_keymap 0 :n))
  (each [_ map (ipairs keymap)]
    (bmap (unpack map))))

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
  (each [_ [mode lhs] (ipairs keymap)]
    (nvim.buf_del_keymap 0 mode lhs)))

(fn M.setup []
  "Configure the plugin with global defaults")

(trace-module M)

