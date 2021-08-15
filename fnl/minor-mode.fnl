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

;; FIXME make this useful for modeline or galaxyline
(fn enabled-list []
  (icollect [mode-name bit-status (pairs minor-modes-enabled)]
    (when (= bit-status 1)
      mode-name)))

(fn enable [mode-name]
  "Activate minor mode"
  (tset minor-modes-enabled mode-name true)
  (local keymap (. keymaps mode-name))
  (each [_ map (ipairs keymap)]
    (bmap (unpack map))))

(fn disable [mode-name]
  "Disable minor-mode keymap"
  (tset minor-modes-enabled mode-name false)
  (local keymap (. keymaps mode-name))
  (each [_ [mode lhs] (ipairs keymap)]
    (nvim.buf_del_keymap 0 mode lhs)))

(fn toggle [mode-name]
  "Toggle a minor mode, enable or disable will be called conditionaly"
  (if (. minor-modes-enabled mode-name)
      (disable mode-name)
      (enable mode-name))
  (print (.. mode-name " " (tostring (. minor-modes-enabled mode-name)))))

(fn define-minor-mode [mode doc-string opts]
  "
  define mode doc minor-mode-opts

  Defines a new minor mode whose name is `mode` (a string). It defines a vim
  command named after `opts.command` to toggle the minor mode, standard vim
  command naming rules apply (:h :user-cmd-ambiguous). Provide a short
  explanation of what the minor mode is in `doc-string` - this value isn't
  exposed anywhere at the moment.

  `minor-mode-opts` is a map, key values are defined below:

  :command command-name

  :keymap keymap

      An array of key bindings that will be actived with the minor mode. Key
      bindings are the same as arguments to nvim_set_keymap (:h nvim_set_keymap())

      Here's an example keymap:

      ```lua
      {
        keymap = {
          { 'n', '<c-p>', ':echo \"down\"', { silent = true } },
          { 'n', '<c-n>', ':echo \"up\"',   { silent = true } } }
      }
      ```
  "
  (local {: command : keymap} opts)
  ;; Option validation
  (assert (-> command (type) (= :string))
          (.. "expected table entry 'command' to be a string, got: "
              (type command)))
  (assert (-> keymap (type) (= :table))
          (.. "expected table entry 'keymap' to be a table, got: "
              (type keymap)))
  ;; Define command to toggle the new minor mode
  (local lua-expr (.. "require('minor-mode').toggle(" (quote-expr mode) ")"))
  (ex (.. "command! " command " :lua " lua-expr :<cr>))
  ;; Add state entries
  (tset minor-modes-enabled mode false)
  (tset keymaps mode keymap))

(fn define [mode command keymap]
  "
  define mode command keymap

  Deprecated, use define-minor-mode
  "
  (print "define is deprecated, use define-minor-mode instead")
  (define-minor-mode mode "" {: command : keymap}))

(local exports {: define
                : define-minor-mode
                :define_minor_mode define-minor-mode
                : disable
                : enable
                : toggle})

(trace-module exports)

