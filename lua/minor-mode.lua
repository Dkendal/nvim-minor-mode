package.preload["minor-mode.trace"] = package.preload["minor-mode.trace"] or function(...)
  local M = {}
  M["trace-fn"] = function(func)
    local function _7_(...)
      local args = {...}
      local function wrapped_func()
        return func(unpack(args))
      end
      local _8_ = {xpcall(wrapped_func, debug.traceback)}
      if ((type(_8_) == "table") and ((_8_)[1] == false) and (nil ~= (_8_)[2])) then
        local err = (_8_)[2]
        return error(err)
      elseif ((type(_8_) == "table") and ((_8_)[1] == true) and (nil ~= (_8_)[2])) then
        local value = (_8_)[2]
        return value
      end
    end
    return _7_
  end
  M["trace-module"] = function(module)
    local function __index(self, key)
      local _10_ = module[key]
      local function _11_()
        local func = _10_
        return (type(func) == "function")
      end
      if ((nil ~= _10_) and _11_()) then
        local func = _10_
        return M["trace-fn"](func)
      elseif (nil ~= _10_) then
        local value = _10_
        return value
      end
    end
    return setmetatable({}, {__index = __index})
  end
  return M
end
package.preload["minor-mode.strings"] = package.preload["minor-mode.strings"] or function(...)
  local M = {}
  local nvim = require("minor-mode.nvim")
  M["quote-expr"] = function(expr)
    return ("\"" .. string.gsub(expr, "\"", "\\\"") .. "\"")
  end
  M.rtc = function(code)
    return nvim.replace_termcodes(code, true, true, true)
  end
  return M
end
package.preload["minor-mode.map"] = package.preload["minor-mode.map"] or function(...)
  local nvim = require("minor-mode.nvim")
  local _local_3_ = require("minor-mode.strings")
  local quote_expr = _local_3_["quote-expr"]
  local rtc = _local_3_["rtc"]
  local M = {}
  M.callbacks = {}
  local function __index(tbl, lhs)
    local stack = debug.traceback()
    return error(("No function handler was defined for the key binding " .. quote_expr(lhs) .. stack))
  end
  setmetatable(M.callbacks, {__index = __index})
  local __module = "minor-mode.map"
  M.bmap = function(mode, lhs, rhs, _3fopts)
    local rhs_ = rhs
    if (type(rhs) == "function") then
      local key = rtc(lhs)
      do end (M.callbacks)[key] = rhs
      local lua_expr = ("require(" .. quote_expr(__module) .. ").callbacks[" .. quote_expr(key) .. "]()")
      rhs_ = ("<cmd>lua " .. lua_expr .. "<cr>")
    end
    return nvim.buf_set_keymap(0, mode, lhs, rhs_, (_3fopts or {}))
  end
  return M
end
package.preload["minor-mode.nvim"] = package.preload["minor-mode.nvim"] or function(...)
  local function _1_(_241, _242)
    return vim.api[("nvim_" .. _242)]
  end
  return setmetatable({}, {__index = _1_})
end
local nvim = require("minor-mode.nvim")
local _local_2_ = require("minor-mode.map")
local bmap = _local_2_["bmap"]
local _local_5_ = require("minor-mode.strings")
local quote_expr = _local_5_["quote-expr"]
local rtc = _local_5_["rtc"]
local _local_6_ = require("minor-mode.trace")
local trace_module = _local_6_["trace-module"]
local api = vim.api
local ex = vim.cmd
local luv = vim.loop
local pack = table.pack
local function pack0(...)
  return {...}, select("#", ...)
end
local M = {}
local keymaps = {}
local minor_modes_enabled = {}
M["enabled-list"] = function()
  local tbl_12_auto = {}
  for mode_name, bit_status in pairs(minor_modes_enabled) do
    local _13_
    if (bit_status == 1) then
      _13_ = mode_name
    else
    _13_ = nil
    end
    tbl_12_auto[(#tbl_12_auto + 1)] = _13_
  end
  return tbl_12_auto
end
M.toggle = function(mode_name)
  if minor_modes_enabled[mode_name] then
    M.disable(mode_name)
  else
    M.enable(mode_name)
  end
  return print((mode_name .. " " .. tostring(minor_modes_enabled[mode_name])))
end
M.define = function(mode_name, command_name, mapping)
  local lua_expr = ("require('minor-mode').toggle(" .. quote_expr(mode_name) .. ")")
  ex(("command! " .. command_name .. " :lua " .. lua_expr .. "<cr>"))
  do end (minor_modes_enabled)[mode_name] = false
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
  for _, _16_ in ipairs(keymap) do
    local _each_17_ = _16_
    local mode = _each_17_[1]
    local lhs = _each_17_[2]
    nvim.buf_del_keymap(0, mode, lhs)
  end
  return nil
end
M.setup = function()
  return "Configure the plugin with global defaults"
end
return trace_module(M)
