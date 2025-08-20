local M = {}
local finder = require("todo-nvim.finder")
local parser = require("todo-nvim.parser")

M.state = {
  buf = nil,
  win = nil,
  todos = {},
  filtered_todos = {},
  filters = {},
  sort_by = "importance"
}

local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "todo")
  vim.api.nvim_buf_set_name(buf, "Todo List")
  
  return buf
end

local function format_todo_display(todo)
  local display = ""
  
  if todo.completed then
    display = "✓ "
  else
    display = "☐ "
  end
  
  -- Show importance and urgency
  if todo.importance or todo.urgency then
    local i = todo.importance or "-"
    local u = todo.urgency or "-"
    display = display .. string.format("[i:%s u:%s] ", i, u)
  elseif todo.priority then
    -- Backward compatibility
    display = display .. string.format("(%s) ", todo.priority)
  end
  
  display = display .. todo.description
  
  local file_info = string.format(" [%s:%d]", 
    vim.fn.fnamemodify(todo.file, ":~:."),
    todo.line_num
  )
  
  return display .. file_info
end

function M.refresh_display()
  if not M.state.buf or not vim.api.nvim_buf_is_valid(M.state.buf) then
    return
  end
  
  vim.api.nvim_buf_set_option(M.state.buf, "modifiable", true)
  
  local lines = {
    "═══════════════════════════════════════════════════════════════",
    "                          TODO LIST                            ",
    "═══════════════════════════════════════════════════════════════",
    "",
  }
  
  table.insert(lines, string.format("Filters: %s | Sort: %s", 
    vim.inspect(M.state.filters):gsub("%s+", " "):gsub("{%s*}", "none"),
    M.state.sort_by
  ))
  table.insert(lines, string.format("Total: %d todos", #M.state.filtered_todos))
  table.insert(lines, "───────────────────────────────────────────────────────────────")
  table.insert(lines, "")
  
  for _, todo in ipairs(M.state.filtered_todos) do
    table.insert(lines, format_todo_display(todo))
  end
  
  if #M.state.filtered_todos == 0 then
    table.insert(lines, "No todos found matching filters")
  end
  
  table.insert(lines, "")
  table.insert(lines, "───────────────────────────────────────────────────────────────")
  table.insert(lines, "Keybindings:")
  table.insert(lines, "  <CR>    - Go to todo")
  table.insert(lines, "  r       - Refresh")
  table.insert(lines, "  fi      - Filter by importance")
  table.insert(lines, "  fU      - Filter by urgency")
  table.insert(lines, "  fc      - Filter by context")  
  table.insert(lines, "  fP      - Filter by project")
  table.insert(lines, "  fs      - Search in descriptions")
  table.insert(lines, "  fu      - Show uncompleted only")
  table.insert(lines, "  fd      - Show completed only")
  table.insert(lines, "  fx      - Clear filters")
  table.insert(lines, "  si      - Sort by importance")
  table.insert(lines, "  sU      - Sort by urgency")
  table.insert(lines, "  sd      - Sort by date")
  table.insert(lines, "  sc      - Sort by completion")
  table.insert(lines, "  q       - Close window")
  
  vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(M.state.buf, "modifiable", false)
end

function M.apply_filters()
  M.state.filtered_todos = finder.filter_todos(M.state.todos, M.state.filters)
  M.state.filtered_todos = finder.sort_todos(M.state.filtered_todos, M.state.sort_by)
  M.refresh_display()
end

function M.setup_keymaps()
  local opts = { noremap = true, silent = true, buffer = M.state.buf }
  
  vim.keymap.set("n", "q", function() M.close() end, opts)
  vim.keymap.set("n", "r", function() M.refresh() end, opts)
  
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local todo_index = line - 8
    
    if todo_index > 0 and todo_index <= #M.state.filtered_todos then
      local todo = M.state.filtered_todos[todo_index]
      M.close()
      vim.cmd("edit " .. todo.file)
      vim.api.nvim_win_set_cursor(0, {todo.line_num, 0})
    end
  end, opts)
  
  vim.keymap.set("n", "fi", function()
    vim.ui.select(
      {"High", "Medium", "Low", "All"},
      { prompt = "Filter by importance: " },
      function(choice)
        if choice == "All" then
          M.state.filters.importance = nil
        else
          M.state.filters.importance = choice:sub(1, 1)
        end
        M.apply_filters()
      end
    )
  end, opts)
  
  vim.keymap.set("n", "fU", function()
    vim.ui.select(
      {"High", "Medium", "Low", "All"},
      { prompt = "Filter by urgency: " },
      function(choice)
        if choice == "All" then
          M.state.filters.urgency = nil
        else
          M.state.filters.urgency = choice:sub(1, 1)
        end
        M.apply_filters()
      end
    )
  end, opts)
  
  vim.keymap.set("n", "fc", function()
    vim.ui.input(
      { prompt = "Filter by context (@): " },
      function(input)
        if input and input ~= "" then
          M.state.filters.context = input
        else
          M.state.filters.context = nil
        end
        M.apply_filters()
      end
    )
  end, opts)
  
  vim.keymap.set("n", "fP", function()
    vim.ui.input(
      { prompt = "Filter by project (+): " },
      function(input)
        if input and input ~= "" then
          M.state.filters.project = input
        else
          M.state.filters.project = nil
        end
        M.apply_filters()
      end
    )
  end, opts)
  
  vim.keymap.set("n", "fs", function()
    vim.ui.input(
      { prompt = "Search in descriptions: " },
      function(input)
        if input and input ~= "" then
          M.state.filters.search = input
        else
          M.state.filters.search = nil
        end
        M.apply_filters()
      end
    )
  end, opts)
  
  vim.keymap.set("n", "fu", function()
    M.state.filters.completed = false
    M.apply_filters()
  end, opts)
  
  vim.keymap.set("n", "fd", function()
    M.state.filters.completed = true
    M.apply_filters()
  end, opts)
  
  vim.keymap.set("n", "fx", function()
    M.state.filters = {}
    M.apply_filters()
  end, opts)
  
  vim.keymap.set("n", "si", function()
    M.state.sort_by = "importance"
    M.apply_filters()
  end, opts)
  
  vim.keymap.set("n", "sU", function()
    M.state.sort_by = "urgency"
    M.apply_filters()
  end, opts)
  
  vim.keymap.set("n", "sd", function()
    M.state.sort_by = "creation_date"
    M.apply_filters()
  end, opts)
  
  vim.keymap.set("n", "sc", function()
    M.state.sort_by = "completion"
    M.apply_filters()
  end, opts)
end

function M.open()
  if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_set_current_win(M.state.win)
    return
  end
  
  M.state.buf = create_buffer()
  
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  M.state.win = vim.api.nvim_open_win(M.state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Todo List ",
    title_pos = "center"
  })
  
  M.setup_keymaps()
  M.refresh()
end

function M.refresh()
  M.state.todos = finder.find_all_todos()
  M.apply_filters()
end

function M.close()
  if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_win_close(M.state.win, true)
  end
  M.state.win = nil
  M.state.buf = nil
end

return M