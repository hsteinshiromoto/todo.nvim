local M = {}
local actions = require("todo-nvim.actions")
local ui = require("todo-nvim.ui")

M.config = {
  keymaps = {
    add_todo = "<localleader>ta",
    toggle_todo = "<localleader>td",
    set_priority = "<localleader>tp",
    open_todo_list = "<localleader>tl"
  }
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      local buf_opts = { noremap = true, silent = true, buffer = true }
      
      vim.keymap.set("n", M.config.keymaps.add_todo, actions.add_todo, 
        vim.tbl_extend("force", buf_opts, { desc = "Add new todo" }))
      
      vim.keymap.set("n", M.config.keymaps.toggle_todo, actions.toggle_todo,
        vim.tbl_extend("force", buf_opts, { desc = "Toggle todo completion" }))
        
      vim.keymap.set("n", M.config.keymaps.set_priority, actions.set_priority,
        vim.tbl_extend("force", buf_opts, { desc = "Set todo priority" }))
    end
  })
  
  vim.keymap.set("n", M.config.keymaps.open_todo_list, ui.open, 
    { noremap = true, silent = true, desc = "Open todo list" })
  
  vim.api.nvim_create_user_command("TodoList", ui.open, {})
  vim.api.nvim_create_user_command("TodoRefresh", ui.refresh, {})
  
  vim.api.nvim_set_hl(0, "TodoCompleted", { fg = "#888888", strikethrough = true })
  vim.api.nvim_set_hl(0, "TodoPriorityA", { fg = "#ff0000", bold = true })
  vim.api.nvim_set_hl(0, "TodoPriorityB", { fg = "#ffa500", bold = true })
  vim.api.nvim_set_hl(0, "TodoPriorityC", { fg = "#ffff00" })
  vim.api.nvim_set_hl(0, "TodoProject", { fg = "#00ff00" })
  vim.api.nvim_set_hl(0, "TodoContext", { fg = "#00ffff" })
  vim.api.nvim_set_hl(0, "TodoDate", { fg = "#888888" })
end

return M