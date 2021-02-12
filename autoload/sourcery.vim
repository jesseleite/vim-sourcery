" ------------------------------------------------------------------------------
" # Pathing
" ------------------------------------------------------------------------------

" Define vim dotfiles path (relative to actual .vimrc file, not symlink)
if empty(get(g:, 'sourcery#vim_dotfiles_path'))
  let g:sourcery#vim_dotfiles_path = fnamemodify(resolve($MYVIMRC), ':h')
endif

" Define system vimfiles path
if empty(get(g:, 'sourcery#system_vimfiles_path'))
  if has('win32')
    let g:sourcery#system_vimfiles_path = $HOME . '/vimfiles'
  else
    let g:sourcery#system_vimfiles_path = $HOME . '/.vim'
  endif
endif

" Get path relative to your vim dotfiles
function! sourcery#vim_dotfiles_path(path)
  return g:sourcery#vim_dotfiles_path . '/' . a:path
endfunction

" Get path relative to your system vimfiles
function! sourcery#system_vimfiles_path(path)
  return g:sourcery#system_vimfiles_path . '/' . a:path
endfunction


" ------------------------------------------------------------------------------
" # Sourcing
" ------------------------------------------------------------------------------

" Source all the conventional things
function! sourcery#source()
  call sourcery#source_file('mappings.vim')
  call sourcery#source_folder('local-config')
  call sourcery#source_folder('plugin-config')
endfunction

" Source a specific file
function! sourcery#source_file(file)
  let file = sourcery#vim_dotfiles_path(a:file)
  if filereadable(file)
    execute 'source' file
  endif
endfunction

" Source everything in a specific folder
function! sourcery#source_folder(folder)
  for config_file in split(glob(sourcery#vim_dotfiles_path(a:folder . '/*')), '\n')
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
    \ sourcery#vim_dotfiles_path('*.vim')
    \ ]
endif

" Autosource all vim configs
augroup sourcery_autosource
  autocmd!
  execute 'autocmd BufWritePost' join(g:sourcery#autosource_paths, ',') 'nested source' $MYVIMRC
augroup END
