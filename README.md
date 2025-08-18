# todo.nvim

A Neovim plugin for managing todo items in Markdown files using the todo.txt format.

## Features

- Add todo items with proper formatting including priority, dates, projects, contexts, and special tags
- Toggle todo completion status
- View all todos across your project/repository in a unified list
- Filter todos by priority, project, context, completion status, or search text
- Sort todos by priority, creation date, or completion status
- Navigate directly to todo items in their source files

## Todo Format

The plugin follows this format for todo items:

```
- [x] (A) 2016-05-20 2016-04-30 measure space for +chapelShelving @chapel due:2016-05-30
   │   │   │          │          │                  │              │        └─> Special key:value tag
   │   │   │          │          │                  │              └─> Context tag
   │   │   │          │          │                  └─> Project tag
   │   │   │          │          └─> Description with tags
   │   │   │          └─> Creation Date
   │   │   └─> Completion Date
   │   └─> Priority (optional)
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
- `<localleader>tp` - Set/change the priority of the todo on the current line

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
- `fp` - Filter by priority (A, B, C, D, or All)
- `fc` - Filter by context (@ tags)
- `fP` - Filter by project (+ tags)
- `fs` - Search in descriptions
- `fu` - Show only uncompleted todos
- `fd` - Show only completed todos
- `fx` - Clear all filters

#### Sorting
- `sp` - Sort by priority
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
2. Press `<localleader>ta`
3. Enter the todo description (can include +project and @context tags)
4. Select a priority (A-D or None)

Example result:
```markdown
- [ ] (A) 2024-01-15 implement new feature +backend @development
```

### Managing Todos

Toggle completion with `<localleader>td`:
```markdown
- [x] (A) 2024-01-15 2024-01-16 implement new feature +backend @development
```

### Viewing All Todos

Press `<localleader>tl` to open the todo list window. You'll see all todos from Markdown files in your project, with options to filter and sort them.

## License

MIT

## Future

- [ ] Improve navigation of todo list window.
- [ ] Add urgent vs import categories.
