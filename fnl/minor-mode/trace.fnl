(local M {})

(fn M.trace-fn [func]
  "Add a stacktrace to the function on error"
  (fn [...]
    (local args [...])

    (fn wrapped-func []
      (func (unpack args)))

    (match [(xpcall wrapped-func debug.traceback)]
      [false err] (error err)
      [true value] value)))

(fn M.trace-module [module]
  "
  Return a new metatable in the place of module. All functions on module are
  wrapped with a traceback error handler
  "
  (fn __index [self key]
    (match (. module key)
      (where func (-> (type func) (= :function))) (M.trace-fn func)
      value value))

  (setmetatable {} {: __index}))

M
