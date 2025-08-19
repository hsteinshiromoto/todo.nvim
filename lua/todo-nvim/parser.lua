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
  
  -- Parse done: and added: dates from the description
  local done_date = rest:match("done:(%d%d%d%d%-%d%d%-%d%d)")
  if done_date then
    todo.completion_date = parse_date(done_date)
    -- Remove done:date from rest for cleaner description
    rest = rest:gsub("done:%d%d%d%d%-%d%d%-%d%d%s*", "")
  end
  
  local added_date = rest:match("added:(%d%d%d%d%-%d%d%-%d%d)")
  if added_date then
    todo.creation_date = parse_date(added_date)
    -- Remove added:date from rest for cleaner description
    rest = rest:gsub("added:%d%d%d%d%-%d%d%-%d%d%s*", "")
  end
  
  todo.description = rest
  
  for project in rest:gmatch("%+(%S+)") do
    table.insert(todo.project_tags, project)
  end
  
  for context in rest:gmatch("@(%S+)") do
    table.insert(todo.context_tags, context)
  end
  
  for key, value in rest:gmatch("(%w+):(%S+)") do
    -- Skip done and added as we already processed them
    if key ~= "done" and key ~= "added" then
      todo.special_tags[key] = value
    end
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
  
  -- Build description with dates as special tags
  local desc_parts = {}
  
  if todo.completed and todo.completion_date then
    table.insert(desc_parts, "done:" .. todo.completion_date.raw)
  end
  
  if todo.creation_date then
    table.insert(desc_parts, "added:" .. todo.creation_date.raw)
  end
  
  -- Add the main description (without the dates as they're already parsed out)
  table.insert(desc_parts, todo.description)
  
  table.insert(parts, table.concat(desc_parts, " "))
  
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