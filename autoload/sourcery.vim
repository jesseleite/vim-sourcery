" ------------------------------------------------------------------------------
" # Pathing
" ------------------------------------------------------------------------------

" Define .vimrc directory path (relative to actual .vimrc file, not symlink)
if empty(get(g:, 'sourcery#vimrc_path'))
  let g:sourcery#vimrc_path = $HOME . '/.dotfiles/vim'
endif

" Define .vim directory path
if empty(get(g:, 'sourcery#dotvim_path'))
  let g:sourcery#dotvim_path = $HOME . '/.vim'
endif

" Get path relative to .vimrc file
function! sourcery#vimrc_path(path)
  return g:sourcery#vimrc_path . '/' . a:path
endfunction

" Get path relative to .vim directory
function! sourcery#dotvim_path(path)
  return g:sourcery#dotvim_path . '/' . a:path
endfunction


" ------------------------------------------------------------------------------
" # Sourcing
" ------------------------------------------------------------------------------

" Source all the conventional things
function! sourcery#source()
  execute 'source ' sourcery#vimrc_path('mappings.vim')
  call sourcery#source_folder('local-config')
  call sourcery#source_folder('plugin-config')
endfunction

" Source everything in a specific folder
function! sourcery#source_folder(folder)
  for config_file in split(glob(sourcery#vimrc_path(a:folder . '/*')), '\n')
    if filereadable(config_file)
      execute 'source' config_file
    endif
  endfor
endfunction


" ------------------------------------------------------------------------------
" # Auto Sourcing
" ------------------------------------------------------------------------------

" Define autosource paths
if empty(get(g:, 'sourcery#autosource_paths'))
  let g:sourcery#autosource_paths = [
    \ $MYVIMRC,
    \ sourcery#vimrc_path('*.vim')
    \ ]
endif

" Autosource all vim configs
augroup sourcery_autosource
  autocmd!
  execute 'autocmd BufWritePost' join(g:sourcery#autosource_paths, ',') 'nested source' $MYVIMRC
augroup END
