# todo.nvim

A Neovim plugin for managing todo items in Markdown files using the todo.txt format with advanced prioritization.

## Features

- Add todo items with proper formatting including importance, urgency, dates, projects, contexts, and special tags
- **Smart prioritization**: Automatically prioritizes tasks based on importance, urgency, and due date proximity
- **Due date support**: Track task deadlines with visual indicators for overdue and upcoming tasks
- Interactive calendar picker for selecting due dates with week numbers
- Toggle todo completion status
- View all todos across your project/repository in a unified list
- **Intelligent filtering**: Filter todos by importance, urgency, priority indicators, project, context, completion status, or search text
- **Composite sorting**: Advanced sorting algorithm that combines multiple priority factors
- Navigate directly to todo items in their source files

## Todo Format

The plugin follows this format for todo items:

```
- [x] done:2016-05-20 added:2016-04-30 i:H u:M measure space for +chapelShelving @chapel due:2016-05-30
   │   │               │                │   │   │                  │              │        └─> Special key:value tag
   │   │               │                │   │   │                  │              └─> Context tag
   │   │               │                │   │   │                  └─> Project tag
   │   │               │                │   │   └─> Description with tags
   │   │               │                │   └─> Urgency (H=High, M=Medium, L=Low)
   │   │               │                └─> Importance (H=High, M=Medium, L=Low)
   │   │               └─> Creation Date (added:YYYY-MM-DD)
   │   └─> Completion Date (done:YYYY-MM-DD)
   └─> Completion Marker (x = completed, space = incomplete)
```

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "hsteinshiromoto/todo.nvim",
  config = function()
    require("todo-nvim").setup({
      keymaps = {
        add_todo = "<localleader>ta",      -- Add new todo
        toggle_todo = "<localleader>td",    -- Toggle completion (done)
        set_priority = "<localleader>tp",   -- Set priority
        open_todo_list = "<localleader>tl"       -- Open todo list
      }
    })
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "hsteinshiromoto/todo.nvim",
  config = function()
    require("todo-nvim").setup()
  end
}
```

## Usage

### In Markdown Files

When editing a Markdown file, use these keybindings:

- `<localleader>ta` - Add a new todo item at the cursor position
- `<localleader>td` - Toggle the completion status of the todo on the current line (mark as done)
- `<localleader>tp` - Set/change the importance and urgency of the todo on the current line

### Global Commands

- `<localleader>tl` or `:TodoList` - Open the todo list window showing all todos in the project
- `:TodoRefresh` - Refresh the todo list

### Todo List Window

When the todo list window is open, you can use these keybindings:

**Note**: By default, the todo list opens showing **incomplete tasks with priority indicators** (importance, urgency, or due dates), sorted by **composite priority score**.

#### Navigation
- `<CR>` - Jump to the todo item in its source file
- `q` - Close the window
- `r` - Refresh the list

#### Filtering
- `fi` - Filter by importance (High, Medium, Low, or All)
- `fU` - Filter by urgency (High, Medium, Low, or All)
- `fp` - **Toggle priority filter** - Show tasks with/without importance, urgency, or due dates
- `fc` - Filter by context (@ tags)
- `fP` - Filter by project (+ tags)
- `fs` - Search in descriptions
- `fu` - Show only uncompleted todos
- `fd` - Show only completed todos
- `fx` - Clear all filters (returns to empty filter state)

#### Sorting
- `sp` - **Sort by composite priority** (combines importance, urgency, and due date proximity)
- `si` - Sort by importance only
- `sU` - Sort by urgency only
- `sd` - Sort by creation date
- `sc` - Sort by completion status

## Configuration

You can customize the keybindings by passing options to the setup function:

```lua
require("todo-nvim").setup({
  keymaps = {
    add_todo = "<localleader>ta",
    toggle_todo = "<localleader>td",
    set_priority = "<localleader>tp",
    open_todo_list = "<localleader>tl"
  }
})
```

## Examples

### Adding a Todo

1. Open a Markdown file
2. Press `<localleader>ta` to open the todo creation window
3. The window opens with:
   - Description field (prompts immediately for input)
   - Importance: None (default) - Press H/M/L/N to change
   - Urgency: None (default) - Press H/M/L/N to change  
   - Due Date: Today's date (default) - Press 'c' to open calendar

#### Todo Creation Window Controls:
- `Tab` or `j` - Move to next field
- `Shift-Tab` or `k` - Move to previous field
- `i` - Edit description
- `H/M/L/N` - Set High/Medium/Low/None for importance or urgency (depending on current field)
- `c` - Open calendar picker when on due date field
- `<CR>` - Save the todo
- `q` or `<Esc>` - Cancel without saving

#### Calendar Navigation (when opened with 'c'):
- `h/l` - Previous/Next day
- `j/k` - Previous/Next week
- `H/L` - Previous/Next month
- `t` - Jump to today
- `<CR>` - Select date
- `q/<Esc>` - Cancel

Example results:

With defaults (None importance/urgency, today's due date):
```markdown
- [ ] added:2024-01-15 implement new feature +backend @development due:2024-01-15
```

With customized values:
```markdown
- [ ] added:2024-01-15 i:H u:M implement new feature +backend @development due:2024-01-30
```

### Managing Todos

Toggle completion with `<localleader>td`:
```markdown
- [x] done:2024-01-16 added:2024-01-15 i:H u:M implement new feature +backend @development
```

Set/change importance and urgency with `<localleader>tp`.

### Viewing All Todos

Press `<localleader>tl` to open the todo list window. You'll see all todos from Markdown files in your project, with options to filter and sort them.

#### Default View
The todo list opens with smart defaults:
- **Shows incomplete tasks only** - Completed tasks are hidden
- **Shows priority tasks only** - Tasks with importance, urgency, or due dates
- **Sorted by composite priority** - Tasks are ordered by combined priority score

#### Priority Scoring System
Tasks are automatically scored based on:
- **Importance**: High = 30 points, Medium = 20 points, Low = 10 points
- **Urgency**: High = 30 points, Medium = 20 points, Low = 10 points  
- **Due Date Proximity**:
  - Overdue = 40 points
  - Due today/tomorrow = 35 points
  - Due within 3 days = 25 points
  - Due within a week = 15 points
  - Due within 2 weeks = 5 points

#### Due Date Indicators
The list displays visual warnings for time-sensitive tasks:
- `⚠ OVERDUE (Xd)` - Task is X days overdue
- `⚠ DUE TODAY` - Task is due today
- `⚠ DUE TOMORROW` - Task is due tomorrow
- `due:Xd` - Task is due in X days (for tasks due within a week)
- `due:YYYY-MM-DD` - Full date for tasks due later

## License

MIT

## Recent Updates

### v0.2.0 (Unreleased)
- ✅ Added support for due dates with `due:YYYY-MM-DD` format
- ✅ Implemented composite priority scoring combining importance, urgency, and due dates
- ✅ Added smart default filters showing incomplete priority tasks
- ✅ Enhanced UI with visual indicators for overdue and upcoming tasks
- ✅ Added priority filter toggle (`fp` keybinding)
- ✅ Added composite priority sort (`sp` keybinding)

## Roadmap

- [ ] Add recurring task support
- [ ] Implement task dependencies
- [ ] Add export functionality (JSON, CSV)
- [ ] Create task statistics dashboard
- [ ] Add time tracking features
