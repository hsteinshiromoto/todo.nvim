local M = {}

local function parse_date(date_str)
  if not date_str or date_str == "" then return nil end
  local year, month, day = date_str:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
  if year and month and day then
    return {year = tonumber(year), month = tonumber(month), day = tonumber(day), raw = date_str}
  end
  return nil
end

function M.parse_todo(line)
  local todo = {
    raw = line,
    completed = false,
    priority = nil,
    completion_date = nil,
    creation_date = nil,
    description = "",
    project_tags = {},
    context_tags = {},
    special_tags = {}
  }
  
  local pattern = "^%-%s*%[([x%s])%]%s*"
  local marker, rest = line:match(pattern)
  
  if not marker then
    return nil
  end
  
  todo.completed = marker == "x"
  rest = line:sub(line:find("%]") + 1):match("^%s*(.*)$")
  
  local priority_match = rest:match("^%(([A-Z])%)%s*")
  if priority_match then
    todo.priority = priority_match
    rest = rest:sub(5)
  end
  
  local date1, date2, remaining
  if todo.completed then
    date1, date2, remaining = rest:match("^(%d%d%d%d%-%d%d%-%d%d)%s+(%d%d%d%d%-%d%d%-%d%d)%s+(.*)$")
    if date1 and date2 then
      todo.completion_date = parse_date(date1)
      todo.creation_date = parse_date(date2)
      rest = remaining
    else
      date1, remaining = rest:match("^(%d%d%d%d%-%d%d%-%d%d)%s+(.*)$")
      if date1 then
        todo.completion_date = parse_date(date1)
        rest = remaining
      end
    end
  else
    date1, remaining = rest:match("^(%d%d%d%d%-%d%d%-%d%d)%s+(.*)$")
    if date1 then
      todo.creation_date = parse_date(date1)
      rest = remaining
    end
  end
  
  todo.description = rest
  
  for project in rest:gmatch("%+(%S+)") do
    table.insert(todo.project_tags, project)
  end
  
  for context in rest:gmatch("@(%S+)") do
    table.insert(todo.context_tags, context)
  end
  
  for key, value in rest:gmatch("(%w+):(%S+)") do
    todo.special_tags[key] = value
  end
  
  return todo
end

function M.format_todo(todo)
  local parts = {}
  
  table.insert(parts, "-")
  
  if todo.completed then
    table.insert(parts, "[x]")
  else
    table.insert(parts, "[ ]")
  end
  
  if todo.priority then
    table.insert(parts, string.format("(%s)", todo.priority))
  end
  
  if todo.completed and todo.completion_date then
    table.insert(parts, todo.completion_date.raw)
  end
  
  if todo.creation_date then
    table.insert(parts, todo.creation_date.raw)
  end
  
  table.insert(parts, todo.description)
  
  return table.concat(parts, " ")
end

function M.create_todo(description, priority)
  local todo = {
    completed = false,
    priority = priority,
    creation_date = {raw = os.date("%Y-%m-%d")},
    description = description,
    project_tags = {},
    context_tags = {},
    special_tags = {}
  }
  
  return M.format_todo(todo)
end

return M