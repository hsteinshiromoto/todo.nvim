local M = {}
local parser = require("todo-nvim.parser")

function M.get_project_root()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  if vim.v.shell_error == 0 and git_root ~= "" then
    return git_root
  end
  return vim.fn.getcwd()
end

function M.find_todos_in_file(filepath)
  local todos = {}
  local file = io.open(filepath, "r")
  if not file then return todos end
  
  local line_num = 0
  for line in file:lines() do
    line_num = line_num + 1
    local todo = parser.parse_todo(line)
    if todo then
      todo.file = filepath
      todo.line_num = line_num
      table.insert(todos, todo)
    end
  end
  
  file:close()
  return todos
end

function M.find_all_todos()
  local root = M.get_project_root()
  local todos = {}
  
  local cmd = string.format(
    "find '%s' -name '*.md' -type f ! -path '*/\\.*' ! -path '*/node_modules/*' 2>/dev/null",
    root
  )
  
  local handle = io.popen(cmd)
  if handle then
    for filepath in handle:lines() do
      local file_todos = M.find_todos_in_file(filepath)
      for _, todo in ipairs(file_todos) do
        table.insert(todos, todo)
      end
    end
    handle:close()
  end
  
  return todos
end

function M.filter_todos(todos, filters)
  if not filters then return todos end
  
  local filtered = {}
  
  for _, todo in ipairs(todos) do
    local match = true
    
    if filters.completed ~= nil and todo.completed ~= filters.completed then
      match = false
    end
    
    if match and filters.priority and todo.priority ~= filters.priority then
      match = false
    end
    
    if match and filters.project then
      local has_project = false
      for _, proj in ipairs(todo.project_tags) do
        if proj:lower():find(filters.project:lower(), 1, true) then
          has_project = true
          break
        end
      end
      if not has_project then match = false end
    end
    
    if match and filters.context then
      local has_context = false
      for _, ctx in ipairs(todo.context_tags) do
        if ctx:lower():find(filters.context:lower(), 1, true) then
          has_context = true
          break
        end
      end
      if not has_context then match = false end
    end
    
    if match and filters.search then
      if not todo.description:lower():find(filters.search:lower(), 1, true) then
        match = false
      end
    end
    
    if match then
      table.insert(filtered, todo)
    end
  end
  
  return filtered
end

function M.sort_todos(todos, sort_by)
  sort_by = sort_by or "priority"
  
  local sort_funcs = {
    priority = function(a, b)
      if a.priority and b.priority then
        return a.priority < b.priority
      elseif a.priority then
        return true
      elseif b.priority then
        return false
      else
        return false
      end
    end,
    creation_date = function(a, b)
      if a.creation_date and b.creation_date then
        return a.creation_date.raw > b.creation_date.raw
      elseif a.creation_date then
        return true
      elseif b.creation_date then
        return false
      else
        return false
      end
    end,
    completion = function(a, b)
      if a.completed == b.completed then
        return false
      else
        return not a.completed
      end
    end
  }
  
  local sort_func = sort_funcs[sort_by] or sort_funcs.priority
  table.sort(todos, sort_func)
  
  return todos
end

return M