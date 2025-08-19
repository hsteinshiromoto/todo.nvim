local M = {}
local parser = require("todo-nvim.parser")
local calendar = require("todo-nvim.calendar")
local input = require("todo-nvim.input")

function M.add_todo()
  input.create_todo_input()
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
    {"High", "Medium", "Low", "None"},
    {
      prompt = "Select importance: ",
    },
    function(importance_choice)
      if not importance_choice then return end
      
      if importance_choice == "None" then
        todo.importance = nil
      else
        todo.importance = importance_choice:sub(1, 1)
      end
      
      vim.ui.select(
        {"High", "Medium", "Low", "None"},
        {
          prompt = "Select urgency: ",
        },
        function(urgency_choice)
          if not urgency_choice then return end
          
          if urgency_choice == "None" then
            todo.urgency = nil
          else
            todo.urgency = urgency_choice:sub(1, 1)
          end
          
          -- Clear old priority format if exists
          todo.priority = nil
          
          local new_line = parser.format_todo(todo)
          local row = vim.api.nvim_win_get_cursor(0)[1]
          vim.api.nvim_buf_set_lines(0, row - 1, row, false, {new_line})
        end
      )
    end
  )
end

return M