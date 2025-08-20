# todo.nvim

A Neovim plugin for managing todo items in Markdown files using the todo.txt format.

## Features

- Add todo items with proper formatting including priority, dates, projects, contexts, and special tags
- Interactive calendar picker for selecting due dates with week numbers
- Toggle todo completion status
- View all todos across your project/repository in a unified list
- Filter todos by priority, project, context, completion status, or search text
- Sort todos by priority, creation date, or completion status
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

#### Navigation
- `<CR>` - Jump to the todo item in its source file
- `q` - Close the window
- `r` - Refresh the list

#### Filtering
- `fi` - Filter by importance (High, Medium, Low, or All)
- `fU` - Filter by urgency (High, Medium, Low, or All)
- `fc` - Filter by context (@ tags)
- `fP` - Filter by project (+ tags)
- `fs` - Search in descriptions
- `fu` - Show only uncompleted todos
- `fd` - Show only completed todos
- `fx` - Clear all filters

#### Sorting
- `si` - Sort by importance
- `sU` - Sort by urgency
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

## License

MIT

## Future

- [ ] Improve navigation of todo list window.
- [ ] Add urgent vs import categories.
