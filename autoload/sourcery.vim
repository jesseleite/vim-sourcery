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
  return expand(g:sourcery#vim_dotfiles_path . '/' . a:path)
endfunction

" Get path relative to your system vimfiles
function! sourcery#system_vimfiles_path(path)
  return expand(g:sourcery#system_vimfiles_path . '/' . a:path)
endfunction


" ------------------------------------------------------------------------------
" # Sourcing
" ------------------------------------------------------------------------------

" Source all the conventional things
function! sourcery#source()
  call sourcery#source_file('mappings.vim')
  call sourcery#source_folder('local-config')
  call sourcery#source_folder('plugin-config')
  call sourcery#autosource_tracked_files()
endfunction

" Source a specific file
function! sourcery#source_file(file)
  let file = sourcery#vim_dotfiles_path(a:file)
  if filereadable(file)
    execute 'source' file
    call s:track(file)
  endif
endfunction

" Source everything in a specific folder
function! sourcery#source_folder(folder)
  let folder = sourcery#vim_dotfiles_path(a:folder) . '/*'
  for file in split(glob(folder, '\n'))
    if filereadable(file)
      execute 'source' file
    endif
  endfor
  call s:track(folder)
endfunction


" ------------------------------------------------------------------------------
" # Auto Sourcing
" ------------------------------------------------------------------------------

" Define autosource paths
if empty(get(g:, 'sourcery#autosource_paths'))
  let g:sourcery#autosource_paths = [
    \ $MYVIMRC,
    \ resolve($MYVIMRC),
    \ sourcery#vim_dotfiles_path('plugins.vim'),
    \ ]
endif

" Track path for autosourcing
function! s:track(path)
  if index(g:sourcery#autosource_paths, a:path) < 0
    call add(g:sourcery#autosource_paths, a:path)
  endif
endfunction

" Autosource all vim configs
function! sourcery#autosource_tracked_files()
  augroup sourcery_autosource
    autocmd!
    execute 'autocmd BufWritePost' join(g:sourcery#autosource_paths, ',') 'nested source' $MYVIMRC
  augroup END
endfunction


" ------------------------------------------------------------------------------
" # Scaffolding
" ------------------------------------------------------------------------------

let s:stub_path = expand('<sfile>:h:h') . '/stub'

function! s:stub_path(path)
  return s:stub_path . '/' . a:path
endfunction

function! s:stub_files()
  let files = []
  for file in globpath(s:stub_path, '**', 0, 1)
    if isdirectory(file) == 0
      call add(files, substitute(file, s:stub_path . '/', '', ''))
    endif
  endfor
  return files
endfunction

function! s:scaffold_file(file)
  let stub_file = s:stub_path(a:file)
  let new_file = sourcery#vim_dotfiles_path(a:file)
  let new_folder = fnamemodify(new_file, ':h')
  if filereadable(new_file) == 0
    call mkdir(new_folder, 'p')
    call writefile(readfile(stub_file), new_file)
    echo 'File added:' new_file
  else
    echo 'Already exists:' new_file
  endif
endfunction

function! sourcery#scaffold()
  let choice = confirm('Scaffold vim configuration to [' . expand(g:sourcery#vim_dotfiles_path) . ']?', "&Yes\n&No")
  if choice == 1
    for file in s:stub_files()
      call s:scaffold_file(file)
    endfor
    echohl
    echo 'Scaffold complete!'
  else
    echohl WarningMsg
    echo 'Scaffold cancelled!'
    echohl None
    echo 'Please define your desired vim dotfiles path and re-run `:SourceryScaffold`.'
    echo "ie) let g:sourcery#vim_dotfiles_path = '~/.dotfiles/vim'"
  endif
endfunction
