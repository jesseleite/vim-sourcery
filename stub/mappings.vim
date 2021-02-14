" ------------------------------------------------------------------------------
" # Mappings
" ------------------------------------------------------------------------------
" # All of your mappings go in this file! Don't worry about your mappings
" # being separate from related config. Sourcery provides mappings to
" # easily jump between plugin definitions, mappings, and configs.
" #
" # More info: https://github.com/jesseleite/vim-sourcery#jumping-between-files


" ------------------------------------------------------------------------------
" # Example
" ------------------------------------------------------------------------------

" " Map leader
" let mapleader = "\<Space>"

" " Exit insert mode
" imap jk <Esc>

" " Vertical split
" nmap <silent> <Leader>v :vsplit<CR>

" " Fzf fuzzy finders
" " Plugin: fzf
" nmap <Leader>f :GFiles<CR>
" nmap <Leader>F :Files<CR>
" nmap <Leader>b :Buffers<CR>
" nmap <Leader>l :BLines<CR>
" nmap <Leader>h :Helptags!<CR>

" " Search project with ag
" " Plugin: agriculture
" nmap <Leader>/ <Plug>AgRawSearch
" vmap <Leader>/ <Plug>AgRawVisualSelection
" nmap <Leader>* <Plug>AgRawWordUnderCursor
