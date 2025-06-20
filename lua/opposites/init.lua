local notify = require('opposites.notify')
local config = require('opposites.config')
local opposites = require('opposites.opposites')
local cases = require('opposites.cases')

---@class opposites
local M = {}

-- Exports the module.
-- So `Opposites.switch()` can be used instead of `require('opposites').switch()`.
-- This only works after the plugin is loaded/required.
-- _G.Opposites = M

---@param opts? opposites.Config
function M.setup(opts)
  -- Checks the supported neovim version.
  if vim.fn.has('nvim-0.10') == 0 then
    notify.error('Requires Neovim >= 0.10')
    return
  end

  -- Setups the plugin.
  config.setup(opts)
end

local function use_module(module)
  -- Gets the current line string and the current cursor position.
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local cursor = { row = row, col = col }

  -- Checks the max allowed line length.
  local line_length = line:len()
  local max_line_length = config.options.max_line_length
  if line_length ~= 0 and line_length > max_line_length then
    notify.error('Line too long: ' .. line_length .. ' (max: ' .. max_line_length .. ')')
    return
  end

  if module == 'opposites' then
    opposites.switch_word_to_opposite_word(line, cursor)
  elseif module == 'cases' then
    cases.switch_word_to_next_case_type(line, cursor)
  end
end

use_module('opposites')

-- Opposites
-- M.switch = opposites.switch_word_to_opposite_word
M.switch = use_module('opposites')

-- Cases
M.cases = {
  -- next = cases.switch_word_to_next_case_type,
  next = use_module('cases'),
}

return M
