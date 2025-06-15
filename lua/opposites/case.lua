local config = require('opposites.config')
local notify = require('opposites.notify')
local util = require('opposites.util')

---@class opposites.cases
local M = {}

-- TODO: Needs refactoring.

---@class opposites.cases.Result
---@field parts table
---@field case_type number

---@enum case_types
local CASE_TYPES = {
  ['snake_case'] = 0,
  ['screaming_snake_case'] = 1,
  ['kebab_case'] = 2,
  ['screaming_kebab_case'] = 3,
  ['camel_case'] = 4,
  ['pascal_case'] = 5,
}

---Parses snake_case.
---@param word string
---@return opposites.cases.Result|boolean
local function parse_snake_case(word)
  local parts = {}
  local part, tail = word:match('^(%l+%d*)(.+)')
  if part then
    table.insert(parts, part)
    while tail ~= nil and tail ~= '' do
      part, tail = tail:match('^_(%l+%d*)(.*)')
      if part == nil then return false end
      table.insert(parts, part)
    end
    return { parts = parts, case_type = CASE_TYPES.snake_case }
  end
  return false
end

---Parses SCREAMING_SNAKE_CASE.
---@param word string
---@return opposites.cases.Result|boolean
local function parse_screaming_snake_case(word)
  local parts = {}
  local part, tail = word:match('^(%u+%d*)(.+)')
  if part then
    table.insert(parts, part)
    while tail ~= nil and tail ~= '' do
      part, tail = tail:match('^_(%u+%d*)(.*)')
      if part == nil then return false end
      table.insert(parts, part)
    end
    return { parts = parts, case_type = CASE_TYPES.screaming_snake_case }
  end
  return false
end

---Parses kebab-case.
---@param word string
---@return opposites.cases.Result|boolean
local function parse_kebab_case(word)
  local parts = {}
  local part, tail = word:match('^(%l+%d*)(.+)')
  if part then
    table.insert(parts, part)
    while tail ~= nil and tail ~= '' do
      part, tail = tail:match('^%-(%l+%d*)(.*)')
      if part == nil then return false end
      table.insert(parts, part)
    end
    return { parts = parts, case_type = CASE_TYPES.kebab_case }
  end
  return false
end

---Parses SCREAMING-KEBAB-CASE.
---@param word string
---@return opposites.cases.Result|boolean
local function parse_screaming_kebab_case(word)
  local parts = {}
  local part, tail = word:match('^(%u+%d*)(.+)')
  if part then
    table.insert(parts, part)
    while tail ~= nil and tail ~= '' do
      part, tail = tail:match('^%-(%u+%d*)(.*)')
      if part == nil then return false end
      table.insert(parts, part)
    end
    return { parts = parts, case_type = CASE_TYPES.screaming_kebab_case }
  end
  return false
end

---Parses camelCase.
---@param word string
---@return opposites.cases.Result|boolean
local function parse_camel_case(word)
  local parts = {}
  local part, tail = word:match('^(%l+%d*)(.+)')
  if part then
    table.insert(parts, part)
    while tail ~= nil and tail ~= '' do
      part, tail = tail:match('^(%u%l+%d*)(.*)')
      if part == nil then return false end
      table.insert(parts, part)
    end
    return { parts = parts, case_type = CASE_TYPES.camel_case }
  end
  return false
end

---Parses PascalCase.
---@param word string
---@return opposites.cases.Result|boolean
local function parse_pascal_case(word)
  local parts = {}
  local part, tail = word:match('^(%u%l+%d*)(.+)')
  if part then
    table.insert(parts, part)
    while tail ~= nil and tail ~= '' do
      part, tail = tail:match('^(%u%l+%d*)(.*)')
      if part == nil then return false end
      table.insert(parts, part)
    end
    return { parts = parts, case_type = CASE_TYPES.pascal_case }
  end
  return false
end

---Parses supported case type.
---@param word string
---@return opposites.cases.Result|boolean
local function parse_supported_case_type(word)
  return parse_snake_case(word)
    or parse_screaming_snake_case(word)
    or parse_kebab_case(word)
    or parse_screaming_kebab_case(word)
    or parse_camel_case(word)
    or parse_pascal_case(word)
end

---Converts to snake_case or SCREAMING_SNAKE_CASE.
---@param parts table
---@param scream? boolean
---@return string
local function convert_to_snake_case(parts, scream)
  local result = table.concat(parts or {}, '_')
  result = scream == true and result:upper() or result:lower()
  return result
end

---Converts to kebab-case or SCREAMING-KEBAB-CASE.
---@paramparts table
---@param scream? boolean
---@return string
local function convert_to_kebab_case(parts, scream)
  parts = parts or {}
  local result = table.concat(parts, '-')
  result = scream == true and result:upper() or result:lower()
  return result
end

---Converts to camelCase.
---@param parts table
---@return string
local function convert_to_camel_case(parts)
  parts = parts or {}
  for i, part in ipairs(parts) do
    if i == 1 then
      parts[i] = part:lower()
    else
      parts[i] = part:sub(1, 1):upper() .. part:sub(2):lower()
    end
  end
  return table.concat(parts, '')
end

---Converts to PascalCase.
---@param parts table
---@return string
local function convert_to_pascal_case(parts)
  parts = parts or {}
  for i, part in ipairs(parts) do
    parts[i] = part:sub(1, 1):upper() .. part:sub(2):lower()
  end
  return table.concat(parts, '')
end

---Converts to case variant.
---@param word string
---@param case_type number
---@return string|boolean
local function convert_word_to_case_type(word, case_type)
  -- Exits if word is nil or empty.
  if word == nil or word == '' then return false end

  -- Parses given word to supported case type.
  local result = parse_supported_case_type(word)
  -- Exits if word is not supported or has less than 2 parts.
  if result == false or #result.parts < 2 then return false end

  -- Returns converted word based on given case type.
  if case_type == CASE_TYPES.snake_case then
    return convert_to_snake_case(result.parts)
  elseif case_type == CASE_TYPES.screaming_snake_case then
    return convert_to_snake_case(result.parts, true)
  elseif case_type == CASE_TYPES.kebab_case then
    return convert_to_kebab_case(result.parts)
  elseif case_type == CASE_TYPES.screaming_kebab_case then
    return convert_to_kebab_case(result.parts, true)
  elseif case_type == CASE_TYPES.camel_case then
    return convert_to_camel_case(result.parts)
  elseif case_type == CASE_TYPES.pascal_case then
    return convert_to_pascal_case(result.parts)
  end

  return false
end

local function switch_to_next_case_type(word)
  -- Exits if word is nil or empty.
  if word == nil or word == '' then return false end

  -- Parses given word to supported case type.
  local result = parse_supported_case_type(word)
  -- Exits if word is not supported or has less than 2 parts.
  if result == false or #result.parts < 2 then return false end

  -- Gets next case type.
  local new_case_type = (result.case_type + 1) % util.table_length(CASE_TYPES)

  -- Returns converted word based on bext case type.
  return convert_word_to_case_type(word, new_case_type)
end

local function find_word_in_line(line, row)
  local pattern = '[a-zA-z0-9_-]+'
  local word_start, word_end

  while true do
    word_start, word_end = line:find(pattern, (word_end or 0) + 1)
    if word_start == nil then break end
    if word_start <= row + 1 and word_end >= row + 1 then
      local word = line:sub(word_start, word_end)
      return word, word_start, word_end
    end
  end

  return nil
end

function M.switch_word_to_next_case_type()
  -- Gets the current line string and the current cursor position.
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- local cursor = { row = row, col = col }

  local word, word_start, word_end = find_word_in_line(line, col)
  if word == nil then
    local row_col_str = '[' .. row .. ':' .. col + 1 .. ']'
    notify.info(row_col_str .. ' No word found')
    return
  end

  -- Checks if the word is nil or empty.
  if word == nil or word == '' then return end

  local new_word = switch_to_next_case_type(word)

  if new_word == false then
    local row_col_str = '[' .. row .. ':' .. col + 1 .. ']'
    notify.info(row_col_str .. ' Word `' .. word .. '` is an unsupported case type')
    return
  end

  -- local new_line = replace_word_in_line(line, word, new_word)
  local left_part = string.sub(line, 1, word_start - 1)
  local right_part = string.sub(line, word_end + 1)
  local new_line = left_part .. new_word .. right_part
  vim.api.nvim_set_current_line(new_line)

  -- Corrects the cursor position if the opposite word is shorter than the word.
  local max_col = word_start - 1 + #new_word - 1
  local new_col = col
  print(max_col, new_col)
  if new_col > max_col then new_col = max_col end

  -- Checks if the cursor position has changed.
  if new_col ~= col then vim.api.nvim_win_set_cursor(0, { row, new_col }) end

  if config.options.notify.found then
    local row_col_str = '[' .. row .. ':' .. col + 1 .. ']'
    notify.info(row_col_str .. ' ' .. word .. ' -> ' .. new_word)
  end
end

return M
