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
    
    if match and filters.has_priority ~= nil then
      local has_priority = todo.importance or todo.urgency or todo.due_date
      if filters.has_priority and not has_priority then
        match = false
      elseif not filters.has_priority and has_priority then
        match = false
      end
    end
    
    if match and filters.priority and todo.priority ~= filters.priority then
      match = false
    end
    
    if match and filters.importance and todo.importance ~= filters.importance then
      match = false
    end
    
    if match and filters.urgency and todo.urgency ~= filters.urgency then
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

local function calculate_priority_score(todo)
  local score = 0
  
  -- Importance contributes to score (H=30, M=20, L=10)
  if todo.importance then
    local importance_scores = {H = 30, M = 20, L = 10}
    score = score + (importance_scores[todo.importance] or 0)
  end
  
  -- Urgency contributes to score (H=30, M=20, L=10)
  if todo.urgency then
    local urgency_scores = {H = 30, M = 20, L = 10}
    score = score + (urgency_scores[todo.urgency] or 0)
  end
  
  -- Due date proximity contributes to score
  if todo.due_date then
    local today = os.date("*t")
    local today_time = os.time({year = today.year, month = today.month, day = today.day})
    local due_time = os.time({year = todo.due_date.year, month = todo.due_date.month, day = todo.due_date.day})
    local days_until_due = (due_time - today_time) / (24 * 60 * 60)
    
    if days_until_due < 0 then
      score = score + 40  -- Overdue
    elseif days_until_due <= 1 then
      score = score + 35  -- Due today or tomorrow
    elseif days_until_due <= 3 then
      score = score + 25  -- Due in 3 days
    elseif days_until_due <= 7 then
      score = score + 15  -- Due this week
    elseif days_until_due <= 14 then
      score = score + 5   -- Due in 2 weeks
    end
  end
  
  return score
end

function M.sort_todos(todos, sort_by)
  sort_by = sort_by or "composite_priority"
  
  local sort_funcs = {
    composite_priority = function(a, b)
      local a_score = calculate_priority_score(a)
      local b_score = calculate_priority_score(b)
      
      if a_score == b_score then
        -- If scores are equal, sort by creation date (newer first)
        if a.creation_date and b.creation_date then
          return a.creation_date.raw > b.creation_date.raw
        end
        return false
      end
      
      return a_score > b_score
    end,
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
    importance = function(a, b)
      local order = {H = 1, M = 2, L = 3}
      local a_val = a.importance and order[a.importance] or 4
      local b_val = b.importance and order[b.importance] or 4
      return a_val < b_val
    end,
    urgency = function(a, b)
      local order = {H = 1, M = 2, L = 3}
      local a_val = a.urgency and order[a.urgency] or 4
      local b_val = b.urgency and order[b.urgency] or 4
      return a_val < b_val
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
  
  local sort_func = sort_funcs[sort_by] or sort_funcs.composite_priority
  table.sort(todos, sort_func)
  
  return todos
end

return M