--------------------------------------------------------------------------------
-- Telescope Finder
--------------------------------------------------------------------------------

local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values

local relative_path = function(path)
    return path:gsub(vim.g['sourcery#vim_dotfiles_path'] .. '/', '')
end

local sourcery = function(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = 'Vim Config',
        sorter = config.generic_sorter(opts),
        previewer = config.grep_previewer(opts),
        finder = finders.new_table {
            results = vim.fn['sourcery#get_normalized_index'](),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.type .. ': ' .. entry.handle .. ' --- ' .. relative_path(entry.file) .. ':' .. entry.line_number,
                    ordinal = entry.type .. entry.handle,
                    filename = entry.file,
                    lnum = entry.line_number,
                    col = 0,
                }
            end,
        },
    }):find()
end

return telescope.register_extension {
    exports = {
        sourcery = sourcery,
    }
}
