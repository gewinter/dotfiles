local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Find in git files' })
vim.keymap.set('n', '<leader>ps', function() 
	builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

require("telescope").setup({
  pickers = {
    oldfiles = {
      only_cwd = true,
    }
  },
})
