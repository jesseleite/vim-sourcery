" ------------------------------------------------------------------------------
" # Initialize Sourcery
" ------------------------------------------------------------------------------

" Initialize all the things
function! sourcery#init()
  call sourcery#source_tracked_paths()
  call sourcery#register_autosourcing()
  call sourcery#register_mappings()
endfunction


" ------------------------------------------------------------------------------
" # Pathing Configuration
" ------------------------------------------------------------------------------

" Define system vimfiles path
if exists('g:sourcery#system_vimfiles_path') == 0
  if has('win32')
    let g:sourcery#system_vimfiles_path = $HOME . '/vimfiles'
  else
    let g:sourcery#system_vimfiles_path = $HOME . '/.vim'
  endif
endif

" Get path relative to your system vimfiles
function! sourcery#system_vimfiles_path(path)
  return expand(g:sourcery#system_vimfiles_path . '/' . a:path)
endfunction

" Define desired vim dotfiles path
if exists('g:sourcery#vim_dotfiles_path') == 0
  let g:sourcery#vim_dotfiles_path = fnamemodify(resolve($MYVIMRC), ':h')
  if (g:sourcery#vim_dotfiles_path == $HOME)
    let g:sourcery#vim_dotfiles_path = g:sourcery#system_vimfiles_path
  endif
endif

" Get path relative to your vim dotfiles
function! sourcery#vim_dotfiles_path(path)
  return expand(g:sourcery#vim_dotfiles_path . '/' . a:path)
endfunction

" Define tracked paths for jump mappings and autosourcing
if exists('g:sourcery#tracked_paths') == 0
  let g:sourcery#tracked_paths = [
    \ $MYVIMRC,
    \ resolve($MYVIMRC),
    \ sourcery#system_vimfiles_path('plugin'),
    \ sourcery#system_vimfiles_path('autoload'),
    \ sourcery#system_vimfiles_path('after'),
    \ ]
endif

" Track another path for jump mappings and autosourcing
function! sourcery#track_path(path)
  if index(g:sourcery#tracked_paths, a:path) < 0
    call add(g:sourcery#tracked_paths, a:path)
  endif
endfunction

" Define paths for sourcing
if exists('g:sourcery#sourced_paths') == 0
  let g:sourcery#sourced_paths = [
    \ sourcery#vim_dotfiles_path('mappings.vim'),
    \ sourcery#vim_dotfiles_path('plugins.vim'),
    \ sourcery#vim_dotfiles_path('config'),
    \ ]
endif

" Source another path
function! sourcery#source_path(path)
  let path = sourcery#vim_dotfiles_path(a:path)
  if index(g:sourcery#sourced_paths, path) < 0
    call add(g:sourcery#sourced_paths, path)
  endif
endfunction


" ------------------------------------------------------------------------------
" # Plugin Configuration
" ------------------------------------------------------------------------------

" Define explicit annotation bindings
if exists('g:sourcery#explicit_plugin_bindings') == 0
  let g:sourcery#explicit_plugin_bindings = {}
endif

" Define plugin definition regex (supports Plug and Vundle by default)
if exists('g:sourcery#plugin_definition_regex') == 0
  let g:sourcery#plugin_definition_regex = escape("^\\s*%(Plug|Plugin)\\s*['\"]([^'\"]*)['\"]", "(|)'%")
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


" ------------------------------------------------------------------------------
" # Sourcing
" ------------------------------------------------------------------------------

" Source and track all configured paths
function! sourcery#source_tracked_paths()
  for path in g:sourcery#sourced_paths
    if isdirectory(path)
      call s:source_folder(path)
    else
      call s:source_file(path)
    endif
  endfor
endfunction

function! s:source_file(file)
  if filereadable(a:file)
    execute 'source' a:file
    call sourcery#track_path(a:file)
  endif
endfunction

function! s:source_folder(folder)
  let folder = a:folder . '/*'
  for file in split(glob(folder, '\n'))
    if filereadable(file)
      execute 'source' file
    endif
  endfor
  call sourcery#track_path(a:folder)
endfunction


" ------------------------------------------------------------------------------
" # Register Auto-Sourcing
" ------------------------------------------------------------------------------

" Register auto-sourcing of vimrc when any tracked configs are saved
function! sourcery#register_autosourcing()
  augroup sourcery_autosource
    autocmd!
    execute 'autocmd BufWritePost' join(s:autocmd_paths(), ',') 'nested source' $MYVIMRC
  augroup END
endfunction


" ------------------------------------------------------------------------------
" # Register Mappings
" ------------------------------------------------------------------------------

" Register vimrc local mappings
function! sourcery#register_mappings()
  " if exists('*VimrcLocalMappings')
  "   augroup sourcery_mappings
  "     autocmd!
  "     execute 'autocmd BufReadPost ' . join(g:sourcery#sourced_paths, ',') . ' call VimrcLocalMappings()'
  "   augroup END
  " endif
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
" # Indexing
" ------------------------------------------------------------------------------

let s:indexed = 0
let s:annotations_index = []
let s:plugin_definitions_index = []
let s:plugin_bindings = {}

function! sourcery#index()
  call s:clear_index()
  for file in s:tracked_files()
    call s:index_annotations(file)
    call s:index_plugin_definitions(file)
  endfor
  call s:merge_plugin_bindings()
  let s:indexed = 1
endfunction

function! s:ensure_index()
  if s:indexed == 1
    return
  endif
  call sourcery#index()
endfunction

function! s:clear_index()
  let s:indexed = 0
  let s:annotations_index = []
  let s:plugin_definitions_index = []
  let s:plugin_bindings = {}
endfunction

function! s:tracked_files()
  let files = []
  for file in g:sourcery#tracked_paths
    if isdirectory(file)
      let files = files + globpath(file, '**', 0, 1)
    else
      call add(files, file)
    endif
  endfor
  return files
endfunction

function! s:autocmd_paths()
  let autocmd_paths = []
  for path in g:sourcery#tracked_paths
    if isdirectory(path)
      call add(autocmd_paths, path . '/*')
    else
      call add(autocmd_paths, path)
    endif
  endfor
  return autocmd_paths
endfunction

function! s:flipped_plugin_bindings()
  let dictionary = s:plugin_bindings
  let flipped = {}
  for [key, value] in items(dictionary)
    let flipped[value] = key
  endfor
  return flipped
endfunction

function! s:index_annotations(file)
  let regex = '^\s*"\s*\(\S*\):\s*\(\S*\)'
  let s:annotations_index = s:annotations_index + s:index_matching_lines(a:file, regex, 'annotation')
endfunction

function! s:index_plugin_definitions(file)
  let s:plugin_definitions_index = s:plugin_definitions_index + s:index_matching_lines(a:file, g:sourcery#plugin_definition_regex, 'plugin')
  for plugin in s:plugin_definitions_index
    let cleaned = substitute(plugin['plugin'], '^.*\/', '', '')
    for ignored in g:sourcery#plugin_definition_ignored_prefixes
      let cleaned = substitute(cleaned, '^' . escape(ignored, '.-'), '', '')
    endfor
    for ignored in g:sourcery#plugin_definition_ignored_suffixes
      let cleaned = substitute(cleaned, escape(ignored, '.-') . '$', '', '')
    endfor
    let s:plugin_bindings[plugin['plugin']] = cleaned
  endfor
endfunction

function! s:index_matching_lines(file, regex, type)
  let index = []
  let lines = readfile(a:file)
  let line_number = 0
  for line in lines
    let line_number = line_number + 1
    let index_match = matchlist(line, a:regex)
    if len(index_match) > 2
      if a:type == 'plugin'
        call add(index, {'line_number': line_number, 'file': a:file, 'type': 'plugin', 'plugin': index_match[1]})
      else
        call add(index, {'line_number': line_number, 'file': a:file, 'type': tolower(index_match[1]), 'slug': index_match[2]})
      endif
    endif
  endfor
  return index
endfunction

function! s:merge_plugin_bindings()
  for [key, value] in items(g:sourcery#explicit_plugin_bindings)
    let s:plugin_bindings[key] = value
  endfor
endfunction


" ------------------------------------------------------------------------------
" # Jumping
" ------------------------------------------------------------------------------

" Go to related mappings
function! sourcery#go_to_related_mappings()
  call s:ensure_index()
  let ref = s:get_ref()
  call s:go_to_annotation('mappings')
endfunction

" Go to related config
function! sourcery#go_to_related_config()
  call s:ensure_index()
  let ref = s:get_ref()
  let config_files = {}
  if ref['slug'] == expand('%:t:r') && ref['type'] == 'config'
    echo 'Cannot find config annotation.'
    return
  endif
  for file in s:tracked_files()
    let config_files[fnamemodify(file, ':t:r')] = file
  endfor
  if has_key(config_files, ref['slug']) && filereadable(config_files[ref['slug']])
    silent execute 'edit' config_files[ref['slug']]
  else
    call s:go_to_annotation('config')
  endif
endfunction

" Go to related plugin definition
function! sourcery#go_to_related_plugin_definition()
  call s:ensure_index()
  let error = 'Cannot find plugin definition.'
  let ref = s:get_ref()
  let flipped_bindings = s:flipped_plugin_bindings()
  if has_key(flipped_bindings, ref['slug'])
    let plugin = flipped_bindings[ref['slug']]
  else
    echo error
    return
  endif
  let matches = filter(copy(s:plugin_definitions_index), "v:val['plugin'] == '" . plugin . "'")
  if len(matches) > 0
    let match = matches[0]
    silent execute 'edit +' . match['line_number'] match['file']
  else
    echo error
  endif
endfunction

function! s:go_to_annotation(type)
  let error = 'Cannot find ' . a:type . ' annotation.'
  let ref = s:get_ref()
  let slug = ref['slug']
  let matches = filter(copy(s:annotations_index), "v:val['type'] == '" . a:type . "' && v:val['slug'] == '" . slug . "'")
  if len(matches) > 0
    let match = matches[0]
    silent execute 'edit +' . match['line_number'] match['file']
  else
    echo error
  endif
endfunction

function! s:get_ref()
  let plugin_match = matchlist(getline('.'), g:sourcery#plugin_definition_regex)
  if len(plugin_match) > 0
    return s:get_ref_from_plug_definition(plugin_match[1])
  endif
  let ref = s:get_ref_from_paragraph_annotation()
  if ref['type'] == 'n/a'
    return s:get_ref_for_current_config_file()
  endif
  return ref
endfunction

function! s:get_ref_from_plug_definition(plugin)
  return {
    \ 'type': 'plugin',
    \ 'slug': s:plugin_bindings[a:plugin]
    \ }
endfunction

function! s:get_ref_from_paragraph_annotation()
  silent normal "lyip
  let paragraph = @l
  let lines = split(paragraph, '\n')
  for line in lines
    let ref_match = matchlist(line, '"\s*\(.*\): \(.*\)')
    if empty(ref_match) == 0
      return {'type': tolower(ref_match[1]), 'slug': ref_match[2]}
    endif
  endfor
  return {'type': 'n/a', 'slug': 'n/a'}
endfunction

function! s:get_ref_for_current_config_file()
  return {'type': 'config', 'slug': expand('%:t:r')}
endfunction
