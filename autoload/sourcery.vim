" ------------------------------------------------------------------------------
" # Pathing
" ------------------------------------------------------------------------------

" Define system vimfiles path
if exists('g:sourcery#system_vimfiles_path') == 0
  if has('win32')
    let g:sourcery#system_vimfiles_path = $HOME . '/vimfiles'
  else
    let g:sourcery#system_vimfiles_path = $HOME . '/.vim'
  endif
endif

" Define desired vim dotfiles path
if exists('g:sourcery#vim_dotfiles_path') == 0
  let g:sourcery#vim_dotfiles_path = fnamemodify(resolve($MYVIMRC), ':h')
  if (g:sourcery#vim_dotfiles_path == $HOME)
    let g:sourcery#vim_dotfiles_path = g:sourcery#system_vimfiles_path
  endif
endif

" Get path relative to your system vimfiles
function! sourcery#system_vimfiles_path(path)
  return expand(g:sourcery#system_vimfiles_path . '/' . a:path)
endfunction

" Get path relative to your vim dotfiles
function! sourcery#vim_dotfiles_path(path)
  return expand(g:sourcery#vim_dotfiles_path . '/' . a:path)
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
  call sourcery#register_mappings()
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
if exists('g:sourcery#autosource_paths') == 0
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

" Base stub path
let s:stub_path = expand('<sfile>:h:h') . '/stub'

" Get path relative to stubs folder
function! s:stub_path(path)
  return s:stub_path . '/' . a:path
endfunction

" List stub files
function! s:stub_files()
  let files = []
  for file in globpath(s:stub_path, '**', 0, 1)
    if isdirectory(file) == 0
      call add(files, substitute(file, s:stub_path . '/', '', ''))
    endif
  endfor
  return files
endfunction

" Scaffold stub file
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

" Scaffold all stub files
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
    echo 'Please define your desired vim dotfiles path above your call to `sourcery#source()` and re-run `:SourceryScaffold`.'
    echo "ie) let g:sourcery#vim_dotfiles_path = '~/.dotfiles/vim'"
  endif
endfunction


" ------------------------------------------------------------------------------
" # Jumping
" ------------------------------------------------------------------------------

" Define explicit annotation bindings
if exists('g:sourcery#explicit_annotation_bindings') == 0
  let g:sourcery#explicit_annotation_bindings = {}
endif

" Define ignored prefixes in plugin definitions
if exists('g:sourcery#plugin_definition_ignored_prefixes') == 0
  let g:sourcery#plugin_definition_ignored_prefixes = [
    \ 'vim-',
    \ 'nvim-',
    \ ]
endif

" Define ignored suffixes in plugin definitions
if exists('g:sourcery#plugin_definition_ignored_suffixes') == 0
  let g:sourcery#plugin_definition_ignored_suffixes = [
    \ '-vim',
    \ '-nvim',
    \ '.vim',
    \ '.nvim',
    \ ]
endif

" Define plugin definition regex (supports Plug and Vundle by default)
if exists('g:sourcery#plugin_definition_regex') == 0
  let g:sourcery#plugin_definition_regex = escape("%(Plug|Plugin).*['\"][^/]*/[^/]*(@PLUGIN@).*['\"]", "(|)'/%")
endif

" Get plugin definition regex for a specific plugin
function! s:plugin_definition_regex(plugin)
  let plugin = a:plugin
  if plugin == 'any'
    let plugin = "[^'\"]*"
  endif
  return substitute(g:sourcery#plugin_definition_regex, '@PLUGIN@', plugin, '')
endfunction

" Go to related plugin definition
function! sourcery#go_to_related_plugin_definition()
  let plugins_path = sourcery#vim_dotfiles_path('plugins.vim')
  let current_file = fnamemodify(@%, ':p')
  let on_plugin_definition_line = match(getline('.'), s:plugin_definition_regex('any')) >= 0
  if plugins_path == current_file && on_plugin_definition_line
    echo 'Already in plugin definitions.'
    return
  endif
  let ref = s:get_ref()
  let plugin = s:get_plugin_from_ref(ref)
  let regex = s:plugin_definition_regex(plugin)
  let plugins = readfile(plugins_path)
  let match = s:match_list_index(plugins, regex)
  if match >= 0
    let line = match + 1
    silent execute 'edit +' . line plugins_path
  else
    echo 'Plugin definition not found.'
  endif
endfunction

" Go to related config
function! sourcery#go_to_related_config()
  let ref = s:get_ref()
  let plugin = s:get_plugin_from_ref(ref)
  let path = sourcery#vim_dotfiles_path(ref['type'] . '-config/' . ref['slug'] . '.vim')
  let current_file = fnamemodify(@%, ':p')
  if path == current_file
    echo 'Already in config for' plugin . '.'
  endif
  if filereadable(path)
    silent execute 'edit ' . path
  elseif ref['type'] == 'plugin'
    call s:go_to_ref(ref, 'plugins.vim', 'config')
  elseif ref['type'] == 'local'
    " TODO: Find reliable way to search for ref in vimrc file
    call s:go_to_ref(ref, 'vimrc', 'config')
  else
    echo 'Ref not found.'
  endif
endfunction

" Go to related mappings
function! sourcery#go_to_related_mappings()
  let ref = s:get_ref()
  call s:go_to_ref(ref, 'mappings.vim', 'mappings')
endfunction

" Register vimrc local mappings
function! sourcery#register_mappings()
  if exists('*VimrcLocalMappings')
    augroup sourcery_mappings
      autocmd!
      execute 'autocmd BufReadPost ' . join(g:sourcery#autosource_paths, ',') . ' call VimrcLocalMappings()'
    augroup END
  endif
endfunction

function! s:get_ref()
  if expand('%:t') == 'plugins.vim' && match(getline('.'), s:plugin_definition_regex('any')) > -1
    return s:get_ref_from_plug_definition()
  elseif expand('%:t') == 'plugins.vim' || expand('%:t') == 'mappings.vim'
    return s:get_ref_from_paragraph_annotation()
  else
    return s:get_ref_for_current_config_file()
  endif
endfunction

function! s:get_ref_from_paragraph_annotation()
  silent normal "lyip
  let paragraph = @l
  let lines = split(paragraph, '\n')
  for line in lines
    let ref = matchlist(line, '"\s*\(.*\): \(.*\)')
    if empty(ref) == 0
      return {'type': tolower(ref[1]), 'slug': ref[2]}
    endif
  endfor
  return {'type': 'n/a', 'slug': 'n/a'}
endfunction

function! s:get_ref_for_current_config_file()
  let ref = matchlist(expand('%:p:r'), '\([^/]*\)-config/\([^/]*\)$')
  return {'type': tolower(ref[1]), 'slug': ref[2]}
endfunction

function! s:get_ref_from_plug_definition()
  " TODO: Use more specific regex with prefixes and suffixes?
  " let matched = matchlist(getline('.'), s:plugin_definition_regex('any'))[1]
  let matched = matchlist(getline('.'), "/\\([^'\"]*\\)")[1]
  let fallback = matched
  for ignored in g:sourcery#plugin_definition_ignored_prefixes
    let fallback = substitute(fallback, '^' . escape(ignored, '.-'), '', '')
  endfor
  for ignored in g:sourcery#plugin_definition_ignored_suffixes
    let fallback = substitute(fallback, escape(ignored, '.-') . '$', '', '')
  endfor
  return {
    \ 'type': 'plugin',
    \ 'slug': get(s:flip_dictionary(g:sourcery#explicit_annotation_bindings), matched, fallback)
    \ }
endfunction

function! s:build_annotation_for_ref(ref)
  return substitute(a:ref['type'], '^.', '\u&', '') . ': ' . a:ref['slug']
endfunction

function! s:get_plugin_from_ref(ref)
  return get(g:sourcery#explicit_annotation_bindings, a:ref['slug'], a:ref['slug'])
endfunction

function! s:go_to_ref(ref, file, config_type)
  let current_ref = s:get_ref_from_paragraph_annotation()
  let current_file = fnamemodify(@%, ':p')
  let file = sourcery#vim_dotfiles_path(a:file)
  let plugin = s:get_plugin_from_ref(a:ref)
  if current_file == file && current_ref == a:ref
    echo 'Already at' a:config_type 'for' plugin . '.'
    return
  endif
  let regex = '".*' . s:build_annotation_for_ref(a:ref)
  let lines = readfile(file)
  let match = s:match_list_index(lines, regex)
  if match >= 0
    let line = match + 1
    silent execute 'edit +' . line file
  else
    echo 'Related' a:config_type 'not found.'
  endif
endfunction

function! s:flip_dictionary(dictionary)
  let flipped = {}
  for [key, value] in items(a:dictionary)
    let flipped[value] = key
  endfor
  return flipped
endfunction

function! s:match_list_index(list, pattern)
  let index = 0
  for item in a:list
    if match(item, a:pattern) >= 0
      return index
    endif
    let index = index + 1
  endfor
  return -1
endfunction
