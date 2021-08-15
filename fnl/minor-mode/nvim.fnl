;; Convenience API for neovim functions
;;
;; Methods like:
;;
;;   vim.api.nvim_buf_set_keymap()
;;
;; can be called like:
;;
;;   nvim.buf_set_keymap()
(setmetatable {} {:__index #(. vim.api (.. :nvim_ $2))})
