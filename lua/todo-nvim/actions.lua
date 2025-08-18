local M = {}
local parser = require("todo-nvim.parser")

function M.add_todo()
  vim.ui.input({
    prompt = "Enter todo description: ",
  }, function(input)
    if not input or input == "" then
      return
    end
    
    vim.ui.select(
      {"A", "B", "C", "D", "None"},
      {
        prompt = "Select priority: ",
      },
      function(choice)
        local priority = nil
        if choice and choice ~= "None" then
          priority = choice
        end
        
        local todo_line = parser.create_todo(input, priority)
        
        local buf = vim.api.nvim_get_current_buf()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        
        vim.api.nvim_buf_set_lines(buf, row, row, false, {todo_line})
        
        vim.api.nvim_win_set_cursor(0, {row + 1, 0})
      end
    )
  end)
end

function M.toggle_todo()
  local line = vim.api.nvim_get_current_line()
  local todo = parser.parse_todo(line)
  
  if not todo then
    vim.notify("Not a valid todo line", vim.log.levels.WARN)
    return
  end
  
  todo.completed = not todo.completed
  if todo.completed then
    todo.completion_date = {raw = os.date("%Y-%m-%d")}
  else
    todo.completion_date = nil
  end
  
  local new_line = parser.format_todo(todo)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, {new_line})
end

function M.set_priority()
  local line = vim.api.nvim_get_current_line()
  local todo = parser.parse_todo(line)
  
  if not todo then
    vim.notify("Not a valid todo line", vim.log.levels.WARN)
    return
  end
  
  vim.ui.select(
    {"A", "B", "C", "D", "None"},
    {
      prompt = "Select priority: ",
    },
    function(choice)
      if not choice then return end
      
      if choice == "None" then
        todo.priority = nil
      else
        todo.priority = choice
      end
      
      local new_line = parser.format_todo(todo)
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, {new_line})
    end
  )
end

return M