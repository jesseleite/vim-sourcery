--------------------------------------------------------------------------------
-- Pathing Helpers
--------------------------------------------------------------------------------

local sourcery = {}

sourcery.system_vimfiles_path = function(path)
    if path then
        return vim.fn['sourcery#system_vimfiles_path'](path)
    end
    return vim.g['sourcery#system_vimfiles_path']
end

sourcery.vim_dotfiles_path = function(path)
    if path then
        return vim.fn['sourcery#vim_dotfiles_path'](path)
    end
    return vim.g['sourcery#vim_dotfiles_path']
end

return sourcery
