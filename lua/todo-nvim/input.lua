local M = {}
local parser = require("todo-nvim.parser")

function M.create_todo_input()
  local buf = vim.api.nvim_create_buf(false, true)
  
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  
  -- Initialize state with defaults
  local state = {
    description = "",
    importance = nil,  -- Default to None
    urgency = nil,     -- Default to None
    due_date = os.date("%Y-%m-%d"),  -- Default to today
    current_field = 1,
    fields = {"description", "importance", "urgency", "due_date"}
  }
  
  local function refresh_display()
    local lines = {
      "═══════════════════════════════════════════════════════════════",
      "                    📝 Create New Todo",
      "═══════════════════════════════════════════════════════════════",
      "",
      (state.current_field == 1 and "▶ " or "  ") .. "Description: " .. (state.description == "" and "[Enter description]" or state.description),
      "",
      (state.current_field == 2 and "▶ " or "  ") .. "Importance:  " .. (state.importance and state.importance or "None") .. " (H/M/L/N)",
      (state.current_field == 3 and "▶ " or "  ") .. "Urgency:     " .. (state.urgency and state.urgency or "None") .. " (H/M/L/N)",
      (state.current_field == 4 and "▶ " or "  ") .. "Due Date:    " .. state.due_date .. " (Press 'c' for calendar)",
      "",
      "───────────────────────────────────────────────────────────────",
      "Preview:",
      "- [ ] added:" .. os.date("%Y-%m-%d") .. 
        (state.importance and " i:" .. state.importance or "") ..
        (state.urgency and " u:" .. state.urgency or "") ..
        " " .. (state.description == "" and "[description]" or state.description) ..
        " due:" .. state.due_date,
      "",
      "───────────────────────────────────────────────────────────────",
      "Navigation:",
      "  Tab/j     - Next field",
      "  Shift-Tab/k - Previous field", 
      "  i         - Edit description",
      "  H/M/L/N   - Set importance/urgency (on respective fields)",
      "  c         - Open calendar (on due date field)",
      "  <CR>      - Save todo",
      "  q/<Esc>   - Cancel"
    }
    
    -- Highlight current field
    local highlight_line = 4 + state.current_field
    if state.current_field == 1 then highlight_line = 5 end
    if state.current_field == 2 then highlight_line = 7 end
    if state.current_field == 3 then highlight_line = 8 end
    if state.current_field == 4 then highlight_line = 9 end
    
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    
    return highlight_line
  end
  
  local width = 65
  local height = 25
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
    title = " New Todo ",
    title_pos = "center"
  })
  
  local function save_todo()
    if state.description == "" then
      vim.notify("Description cannot be empty", vim.log.levels.WARN)
      return
    end
    
    local desc = state.description .. " due:" .. state.due_date
    local todo_line = parser.create_todo(desc, nil, state.importance, state.urgency)
    
    vim.api.nvim_win_close(win, true)
    
    local target_buf = vim.api.nvim_get_current_buf()
    local target_row = vim.api.nvim_win_get_cursor(0)[1]
    
    vim.api.nvim_buf_set_lines(target_buf, target_row, target_row, false, {todo_line})
    vim.api.nvim_win_set_cursor(0, {target_row + 1, 0})
  end
  
  local function cancel()
    vim.api.nvim_win_close(win, true)
  end
  
  local function move_field(delta)
    state.current_field = state.current_field + delta
    if state.current_field < 1 then state.current_field = #state.fields end
    if state.current_field > #state.fields then state.current_field = 1 end
    local line = refresh_display()
    vim.api.nvim_win_set_cursor(win, {line, 0})
  end
  
  local function set_importance_urgency(value)
    if state.current_field == 2 then
      state.importance = value ~= "N" and value or nil
    elseif state.current_field == 3 then
      state.urgency = value ~= "N" and value or nil
    end
    refresh_display()
  end
  
  local function edit_description()
    vim.ui.input({
      prompt = "Enter todo description: ",
      default = state.description
    }, function(input)
      if input then
        state.description = input
        refresh_display()
      end
    end)
  end
  
  local function open_calendar()
    if state.current_field == 4 then
      local calendar = require("todo-nvim.calendar")
      calendar.create_calendar_window(function(selected_date)
        if selected_date then
          state.due_date = selected_date
          refresh_display()
        end
      end)
    else
      vim.notify("Navigate to the Due Date field first (use Tab/j)", vim.log.levels.INFO)
    end
  end
  
  -- Setup keymaps
  local opts = { noremap = true, silent = true, buffer = buf }
  
  vim.keymap.set("n", "<Tab>", function() move_field(1) end, opts)
  vim.keymap.set("n", "j", function() move_field(1) end, opts)
  vim.keymap.set("n", "<S-Tab>", function() move_field(-1) end, opts)
  vim.keymap.set("n", "k", function() move_field(-1) end, opts)
  
  vim.keymap.set("n", "i", edit_description, opts)
  
  vim.keymap.set("n", "H", function() set_importance_urgency("H") end, opts)
  vim.keymap.set("n", "M", function() set_importance_urgency("M") end, opts)
  vim.keymap.set("n", "L", function() set_importance_urgency("L") end, opts)
  vim.keymap.set("n", "N", function() set_importance_urgency("N") end, opts)
  
  vim.keymap.set("n", "c", open_calendar, opts)
  
  vim.keymap.set("n", "<CR>", save_todo, opts)
  vim.keymap.set("n", "q", cancel, opts)
  vim.keymap.set("n", "<Esc>", cancel, opts)
  
  -- Initial display
  local initial_line = refresh_display()
  vim.api.nvim_win_set_cursor(win, {initial_line, 0})
  
  -- Immediately prompt for description
  vim.schedule(function()
    edit_description()
  end)
  
  return win, buf
end

return M