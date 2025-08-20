local M = {}

local function get_week_number(date)
  local year = date.year
  local month = date.month
  local day = date.day
  
  local a = (14 - month) / 12
  local y = year + 4800 - a
  local m = month + 12 * a - 3
  
  local julian = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
  
  local d4 = (julian + 31741 - (julian % 7)) % 146097 % 36524 % 1461
  local L = d4 / 1460
  local d1 = ((d4 - L) % 365) + L
  
  return math.floor(d1 / 7) + 1
end

local function get_days_in_month(year, month)
  local days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
  
  if month == 2 and ((year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)) then
    return 29
  end
  
  return days[month]
end

local function get_first_day_of_week(year, month)
  local t = os.time({year = year, month = month, day = 1})
  return tonumber(os.date("%w", t))
end

function M.generate_calendar(year, month)
  local lines = {}
  local month_names = {"January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"}
  
  table.insert(lines, string.format("         %s %d", month_names[month], year))
  table.insert(lines, "")
  table.insert(lines, " Wk  Sun Mon Tue Wed Thu Fri Sat")
  table.insert(lines, "───  ─── ─── ─── ─── ─── ─── ───")
  
  local days_in_month = get_days_in_month(year, month)
  local first_day = get_first_day_of_week(year, month)
  
  local day = 1
  local week_num = get_week_number({year = year, month = month, day = 1})
  
  for week = 0, 5 do
    if day > days_in_month then
      break
    end
    
    local line = string.format("%3d  ", week_num)
    
    for weekday = 0, 6 do
      if week == 0 and weekday < first_day then
        line = line .. "    "
      elseif day > days_in_month then
        line = line .. "    "
      else
        line = line .. string.format("%3d ", day)
        day = day + 1
      end
    end
    
    table.insert(lines, line)
    week_num = week_num + 1
  end
  
  return lines
end

function M.create_calendar_window(on_select_callback)
  local buf = vim.api.nvim_create_buf(false, true)
  
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  
  local current_date = os.date("*t")
  local state = {
    year = current_date.year,
    month = current_date.month,
    selected_day = current_date.day,
    callback = on_select_callback
  }
  
  local function refresh_calendar()
    local lines = {}
    
    table.insert(lines, "═══════════════════════════════════════")
    table.insert(lines, "        📅 Select Due Date")
    table.insert(lines, "═══════════════════════════════════════")
    table.insert(lines, "")
    
    local cal1 = M.generate_calendar(state.year, state.month)
    for _, line in ipairs(cal1) do
      table.insert(lines, line)
    end
    
    table.insert(lines, "")
    table.insert(lines, "───────────────────────────────────────")
    table.insert(lines, "")
    
    local next_month = state.month + 1
    local next_year = state.year
    if next_month > 12 then
      next_month = 1
      next_year = next_year + 1
    end
    
    local cal2 = M.generate_calendar(next_year, next_month)
    for _, line in ipairs(cal2) do
      table.insert(lines, line)
    end
    
    table.insert(lines, "")
    table.insert(lines, "───────────────────────────────────────")
    table.insert(lines, "Keybindings:")
    table.insert(lines, "  h/l     - Previous/Next day")
    table.insert(lines, "  j/k     - Previous/Next week")
    table.insert(lines, "  H/L     - Previous/Next month")
    table.insert(lines, "  <CR>    - Select date")
    table.insert(lines, "  <Tab>   - Jump to next month")
    table.insert(lines, "  t       - Today")
    table.insert(lines, "  q/<Esc> - Cancel")
    
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end
  
  local width = 41
  local height = 30
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Calendar ",
    title_pos = "center"
  })
  
  local function move_day(delta)
    state.selected_day = state.selected_day + delta
    local days_in_month = get_days_in_month(state.year, state.month)
    
    if state.selected_day > days_in_month then
      state.selected_day = 1
      state.month = state.month + 1
      if state.month > 12 then
        state.month = 1
        state.year = state.year + 1
      end
    elseif state.selected_day < 1 then
      state.month = state.month - 1
      if state.month < 1 then
        state.month = 12
        state.year = state.year - 1
      end
      state.selected_day = get_days_in_month(state.year, state.month)
    end
    
    refresh_calendar()
  end
  
  local function move_month(delta)
    state.month = state.month + delta
    if state.month > 12 then
      state.month = 1
      state.year = state.year + 1
    elseif state.month < 1 then
      state.month = 12
      state.year = state.year - 1
    end
    
    local days_in_month = get_days_in_month(state.year, state.month)
    if state.selected_day > days_in_month then
      state.selected_day = days_in_month
    end
    
    refresh_calendar()
  end
  
  local function select_date()
    local date_str = string.format("%04d-%02d-%02d", state.year, state.month, state.selected_day)
    vim.api.nvim_win_close(win, true)
    if state.callback then
      state.callback(date_str)
    end
  end
  
  local function cancel()
    vim.api.nvim_win_close(win, true)
    if state.callback then
      state.callback(nil)
    end
  end
  
  local opts = { noremap = true, silent = true, buffer = buf }
  
  vim.keymap.set("n", "h", function() move_day(-1) end, opts)
  vim.keymap.set("n", "l", function() move_day(1) end, opts)
  vim.keymap.set("n", "j", function() move_day(7) end, opts)
  vim.keymap.set("n", "k", function() move_day(-7) end, opts)
  vim.keymap.set("n", "H", function() move_month(-1) end, opts)
  vim.keymap.set("n", "L", function() move_month(1) end, opts)
  vim.keymap.set("n", "<Tab>", function() move_month(1) end, opts)
  vim.keymap.set("n", "t", function()
    local today = os.date("*t")
    state.year = today.year
    state.month = today.month
    state.selected_day = today.day
    refresh_calendar()
  end, opts)
  vim.keymap.set("n", "<CR>", select_date, opts)
  vim.keymap.set("n", "q", cancel, opts)
  vim.keymap.set("n", "<Esc>", cancel, opts)
  
  refresh_calendar()
  
  local cursor_line = 8
  for week = 0, 5 do
    local first_day = get_first_day_of_week(state.year, state.month)
    local day_position = (state.selected_day + first_day - 1)
    if day_position >= week * 7 + 1 and day_position <= (week + 1) * 7 then
      cursor_line = 8 + week
      break
    end
  end
  
  vim.api.nvim_win_set_cursor(win, {cursor_line, 5})
  
  return win, buf
end

return M