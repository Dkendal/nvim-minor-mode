(local M {})

(local nvim (require :minor-mode.nvim))

(fn M.quote-expr [expr]
  "Surround expr with double quotes, and escape any double quotes."
  (.. "\"" (string.gsub expr "\"" "\\\"") "\""))

(fn M.rtc [code]
  "Replace termcodes"
  (nvim.replace_termcodes code true true true))

M
