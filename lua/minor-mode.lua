local api = vim.api
local ex = vim.cmd
local luv = vim.loop
local pack = table.pack
local function pack0(...)
  return {...}, select("#", ...)
end
local nvim = {}
local function _0_(_241, _242)
  return vim.api[("nvim_" .. _242)]
end
setmetatable(nvim, {__index = _0_})
local M = {}
local keymaps = {}
local minor_modes_enabled = {}
local counter = {n = -1}
local function _1_(self)
  self.n = (self + 1)
  return self.n
end
setmetatable(counter, {__call = _1_})
local function trace(func)
  local function _2_(...)
    local args = {...}
    local function wrapped_func()
      return func(unpack(args))
    end
    local _3_ = {xpcall(wrapped_func, debug.traceback)}
    if ((type(_3_) == "table") and ((_3_)[1] == false) and (nil ~= (_3_)[2])) then
      local err = (_3_)[2]
      return error(err)
    elseif ((type(_3_) == "table") and ((_3_)[1] == true) and (nil ~= (_3_)[2])) then
      local value = (_3_)[2]
      return value
    end
  end
  return _2_
end
M.callbacks = {}
M["enabled-list"] = function()
  local tbl_0_ = {}
  for mode_name, bit_status in pairs(minor_modes_enabled) do
    local _2_
    if (bit_status == 1) then
      _2_ = mode_name
    else
    _2_ = nil
    end
    tbl_0_[(#tbl_0_ + 1)] = _2_
  end
  return tbl_0_
end
local function rtc(code)
  return nvim.replace_termcodes(code, true, true, true)
end
local function quote_expr(expr)
  return ("\"" .. string.gsub(expr, "\"", "\\\"") .. "\"")
end
local function bmap(mode, lhs, rhs, _3fopts)
  local rhs_ = rhs
  if (type(rhs) == "function") then
    local key = rtc(lhs)
    M.callbacks[key] = rhs
    local lua_expr = ("require('minor-mode').callbacks[" .. quote_expr(key) .. "]()")
    rhs_ = ("<cmd>lua " .. lua_expr .. "<cr>")
  end
  return nvim.buf_set_keymap(0, mode, lhs, rhs_, (_3fopts or {}))
end
M.toggle = function(mode_name)
  print((mode_name .. " " .. tostring(not minor_modes_enabled[mode_name])))
  if minor_modes_enabled[mode_name] then
    return M.disable(mode_name)
  else
    return M.enable(mode_name)
  end
end
M.define = function(mode_name, command_name, mapping)
  local lua_expr = ("require('minor-mode').toggle(" .. quote_expr(mode_name) .. ")")
  ex(("command! " .. command_name .. " :lua " .. lua_expr .. "<cr>"))
  minor_modes_enabled[mode_name] = false
  keymaps[mode_name] = mapping
  return nil
end
M.enable = function(mode_name)
  minor_modes_enabled[mode_name] = true
  local keymap = keymaps[mode_name]
  for _, map in ipairs(keymap) do
    bmap(unpack(map))
  end
  return nil
end
M.disable = function(mode_name)
  minor_modes_enabled[mode_name] = false
  local keymap = keymaps[mode_name]
  for lhs, _ in pairs(keymap) do
    nvim.buf_del_keymap(0, "n", lhs)
  end
  return nil
end
M.setup = function()
  return "Configure the plugin with global defaults"
end
local traced_module = {}
local function _2_(self, key)
  local _3_ = M[key]
  local function _4_()
    local func = _3_
    return (type(func) == "function")
  end
  if ((nil ~= _3_) and _4_()) then
    local func = _3_
    return trace(func)
  elseif (nil ~= _3_) then
    local value = _3_
    return value
  end
end
setmetatable(traced_module, {__index = _2_})
return traced_module
