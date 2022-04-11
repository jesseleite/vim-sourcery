" ------------------------------------------------------------------------------
" # Initialize Sourcery
" ------------------------------------------------------------------------------

" Initialize all the things
function! sourcery#init()
  call sourcery#source_and_track_paths()
  call sourcery#register_autosourcing()
  call sourcery#register_mappings()
endfunction


" ------------------------------------------------------------------------------
" # Pathing Configuration
" ------------------------------------------------------------------------------

" Disable sourcing on boot
if exists('g:sourcery#disable_sourcing_on_boot') == 0
  let g:sourcery#disable_sourcing_on_boot = 0
endif

" Disable auto-sourcing on save
if exists('g:sourcery#disable_autosourcing_on_save') == 0
  let g:sourcery#disable_autosourcing_on_save = 0
endif

" Define system vimfiles path
if exists('g:sourcery#system_vimfiles_path') == 0
  if has('nvim')
    let g:sourcery#system_vimfiles_path = stdpath('config')
  elseif has('win32')
    let g:sourcery#system_vimfiles_path = $HOME . '/vimfiles'
  else
    let g:sourcery#system_vimfiles_path = $HOME . '/.vim'
  endif
endif

" Get path relative to your system vimfiles
function! sourcery#system_vimfiles_path(path)
  if matchstrpos(expand(a:path), '/')[1] == 0
    return a:path
  endif
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
  if matchstrpos(expand(a:path), '/')[1] == 0
    return a:path
  endif
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
    \ sourcery#system_vimfiles_path('lua'),
    \ ]
endif

" Track another path for jump mappings and autosourcing
function! sourcery#track_path(path)
  let path = sourcery#vim_dotfiles_path(a:path)
  if index(g:sourcery#tracked_paths, path) < 0
    call add(g:sourcery#tracked_paths, path)
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

" Define paths for deferring sourcing
if exists('g:sourcery#deferred_source_paths') == 0
  let g:sourcery#deferred_source_paths = []
endif

" Defer sourcing of a path to ensure it gets sourced at the end
function! sourcery#source_defer(path)
  let path = sourcery#vim_dotfiles_path(a:path)
  if index(g:sourcery#deferred_source_paths, path) < 0
    call add(g:sourcery#deferred_source_paths, path)
  endif
endfunction


" ------------------------------------------------------------------------------
" # Plugin Configuration
" ------------------------------------------------------------------------------

" Define explicit annotation bindings
if exists('g:sourcery#explicit_plugin_bindings') == 0
  let g:sourcery#explicit_plugin_bindings = {}
endif

" Define plugin definition regex (supports packadd, Plug, and Vundle by default)
if exists('g:sourcery#plugin_definition_regex') == 0
  let g:sourcery#plugin_definition_regex = escape("^\\s*(\"*)[\" ]*(pa[ckad!]*|Plug|Plugin)\\s+['\"]?([^'\"=]+)['\"]?", "(|)'+?=")
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

" Define plugin definition paths for smarter sourcing and when plugins are disabled
if exists('g:sourcery#plugin_definition_paths') == 0
  let g:sourcery#plugin_definition_paths = [
    \ sourcery#vim_dotfiles_path('plugins.vim'),
    \ ]
endif

" Define ignored plugin definition paths, in case they contain interfering definitions
if exists('g:sourcery#plugin_definition_ignored_paths') == 0
  let g:sourcery#plugin_definition_ignored_paths = [
    \ sourcery#system_vimfiles_path('autoload/plug.vim'),
    \ sourcery#system_vimfiles_path('bundle/Vundle.vim'),
    \ ]
endif


" ------------------------------------------------------------------------------
" # Annotation Configuration
" ------------------------------------------------------------------------------

" Define indexable annotation types
if exists('g:sourcery#annotation_types') == 0
  let g:sourcery#annotation_types = [
    \ 'Mappings',
    \ 'Config',
    \ ]
endif

" Define annotation regex
if exists('g:sourcery#annotation_regex') == 0
  let types = join(g:sourcery#annotation_types, '|')
  let g:sourcery#annotation_regex = escape("^\\s*%([\"-]+\\s*)*(" . types . "):\\s*(\\S*)", "(|)%+")
endif


" ------------------------------------------------------------------------------
" # Sourcing
" ------------------------------------------------------------------------------

let s:sourced_files = []

" Source and track all configured paths
function! sourcery#source_and_track_paths()
  for path in g:sourcery#sourced_paths
    call sourcery#track_path(path)
  endfor
  for path in g:sourcery#deferred_source_paths
    call sourcery#track_path(path)
  endfor
  if g:sourcery#disable_sourcing_on_boot
    return
  endif
  call s:index_disabled_plugins()
  for file in filter(s:get_files_from_paths(g:sourcery#sourced_paths), "index(g:sourcery#deferred_source_paths, v:val) < 0")
    call s:source_file(file)
  endfor
  for file in s:get_files_from_paths(g:sourcery#deferred_source_paths)
    call s:source_file(file)
  endfor
endfunction

function! s:source_file(file)
  if s:should_source_file_by_extension(a:file, 'vim')
    execute 'source' a:file
    call add(s:sourced_files, a:file)
  elseif s:should_source_file_by_extension(a:file, 'lua') && has('nvim')
    execute 'luafile' a:file
    call add(s:sourced_files, a:file)
  endif
endfunction

function! s:should_source_file_by_extension(file, extension)
  let extension = fnamemodify(a:file, ':e')
  if extension != a:extension
    return 0
  endif
  return s:should_source_file(a:file)
endfunction

function! s:should_source_file(file)
  let handle = fnamemodify(a:file, ':t:r')
  if filereadable(a:file) == 0 || index(s:disabled_plugins, handle) >= 0
    return 0
  endif
  return 1
endfunction


" ------------------------------------------------------------------------------
" # Register Auto-Sourcing
" ------------------------------------------------------------------------------

function! s:re_source()
  let file = expand('%:p')
  if matchstrpos(file, g:sourcery#system_vimfiles_path)[1] == 0
    call s:source_file(file)
  endif
  call s:source_file($MYVIMRC)
  call sourcery#index()
endfunction

" Register auto-sourcing of vimrc when any tracked configs are saved
function! sourcery#register_autosourcing()
  if g:sourcery#disable_autosourcing_on_save
    return
  endif
  augroup sourcery_autosource
    autocmd!
    execute 'autocmd BufWritePost' s:autocmd_paths() 'nested call s:re_source()'
  augroup END
endfunction


" ------------------------------------------------------------------------------
" # Register Mappings
" ------------------------------------------------------------------------------

" Register vimrc local mappings
function! sourcery#register_mappings()
  if exists('*SourceryMappings')
    augroup sourcery_mappings
      autocmd!
      execute 'autocmd BufReadPost' s:autocmd_paths() 'call SourceryMappings()'
    augroup END
  endif
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
  if matchstrpos(new_folder, g:sourcery#system_vimfiles_path)[1] == 0
    let new_file = substitute(new_file, '/config', '/plugin', '')
    let new_folder = substitute(new_folder, '/config', '/plugin', '')
  endif
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
let s:tracked_files_index = []
let s:annotations_index = []
let s:plugin_definitions_index = []
let s:plugin_bindings = {}
let s:disabled_plugins = []

function! sourcery#index()
  call s:clear_index()
  for file in s:get_files_from_paths(g:sourcery#tracked_paths)
    call s:index_file(file)
    call s:index_annotations(file)
    call s:index_plugin_definitions(file)
  endfor
  call s:merge_plugin_bindings()
  let s:indexed = 1
endfunction

function! sourcery#get_normalized_index()
  call s:ensure_index()
  let normalized = []
  for file in s:indexed_files
    call add(normalized, {
      \ 'type': 'File',
      \ 'file': file,
      \ 'handle': fnamemodify(file, ':t'),
      \ 'line_number': 0,
      \ })
  endfor
  for index in s:plugin_definitions_index
    call add(normalized, {
      \ 'type': 'Plugin Definition',
      \ 'file': index['file'],
      \ 'handle': s:plugin_bindings[index['plugin']],
      \ 'line_number': index['line_number'],
      \ })
  endfor
  for index in s:annotations_index
    call add(normalized, {
      \ 'type': substitute(index['type'], '^.', '\u&', ''),
      \ 'file': index['file'],
      \ 'handle': index['handle'],
      \ 'line_number': index['line_number'],
      \ })
  endfor
  return normalized
endfunction

function! s:ensure_index()
  if s:indexed == 1
    return
  endif
  call sourcery#index()
endfunction

function! s:clear_index()
  let s:indexed = 0
  let s:indexed_files = []
  let s:annotations_index = []
  let s:plugin_definitions_index = []
  let s:plugin_bindings = {}
  let s:disabled_plugins = []
endfunction

function! s:index_disabled_plugins()
  let disabled = []
  for file in g:sourcery#plugin_definition_paths
    if filereadable(file)
      for index in s:index_matching_lines(file, g:sourcery#plugin_definition_regex, 'plugin')
        if index['disabled']
          call add(disabled, s:get_plugin_handle(index['plugin']))
        endif
      endfor
    endif
  endfor
  let s:disabled_plugins = disabled
endfunction

function! s:autocmd_paths()
  let autocmd_paths = []
  for path in g:sourcery#tracked_paths
    if isdirectory(path)
      call add(autocmd_paths, path . '/*.vim')
      call add(autocmd_paths, path . '/*.lua')
    else
      call add(autocmd_paths, path)
    endif
  endfor
  return join(autocmd_paths, ',')
endfunction

function! s:flipped_plugin_bindings()
  let dictionary = s:plugin_bindings
  let flipped = {}
  for [key, value] in items(dictionary)
    let flipped[value] = key
  endfor
  return flipped
endfunction

function! s:index_file(file)
  let resolved = resolve(a:file)
  if index(s:indexed_files, resolved) == -1
    call add(s:indexed_files, resolved)
  endif
endfunction

function! s:index_annotations(file)
  let s:annotations_index = s:annotations_index + s:index_matching_lines(a:file, g:sourcery#annotation_regex, 'annotation')
endfunction

function! s:index_plugin_definitions(file)
  if index(g:sourcery#plugin_definition_ignored_paths, a:file) >= 0
    return
  endif
  let s:plugin_definitions_index = s:plugin_definitions_index + s:index_matching_lines(a:file, g:sourcery#plugin_definition_regex, 'plugin')
  for plugin in s:plugin_definitions_index
    let s:plugin_bindings[plugin['plugin']] = s:get_plugin_handle(plugin['plugin'])
  endfor
endfunction

function! s:get_plugin_handle(plugin_path)
  let handle = substitute(a:plugin_path, '^.*\/', '', '')
  for ignored in g:sourcery#plugin_definition_ignored_prefixes
    let handle = substitute(handle, '^' . escape(ignored, '.-'), '', '')
  endfor
  for ignored in g:sourcery#plugin_definition_ignored_suffixes
    let handle = substitute(handle, escape(ignored, '.-') . '$', '', '')
  endfor
  return handle
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
        call add(index, {
          \ 'line_number': line_number,
          \ 'file': a:file,
          \ 'line' : line,
          \ 'type': 'plugin',
          \ 'plugin': index_match[3],
          \ 'disabled': len(index_match[1]) > 0,
          \ })
      else
        call add(index, {
          \ 'line_number': line_number,
          \ 'file': a:file,
          \ 'line': line,
          \ 'type': tolower(index_match[1]),
          \ 'handle': index_match[2],
          \ })
      endif
    endif
  endfor
  return index
endfunction

function! s:filter_index_by_path(index, path_regex)
  let index = copy(a:index)
  let matches = filter(index, "match(v:val['file'], a:path_regex) >= 0")
  return matches
endfunction

function! s:merge_plugin_bindings()
  for [key, value] in items(g:sourcery#explicit_plugin_bindings)
    let s:plugin_bindings[key] = value
  endfor
endfunction

function! s:get_files_from_paths(paths)
  let files = []
  for file in a:paths
    if isdirectory(file)
      let files = files + globpath(file, '**/*.*', 0, 1)
    else
      if filereadable(file)
        call add(files, file)
      endif
    endif
  endfor
  return files
endfunction

function! s:filter_files_by_path(files, path_regex)
  let files = copy(a:files)
  let matches = filter(files, "match(v:val, a:path_regex) >= 0")
  return matches
endfunction


" ------------------------------------------------------------------------------
" # Jumping
" ------------------------------------------------------------------------------

" Go to related files and/or anotation type
function! sourcery#go_to_related(attempt_file_first, annotation_type, ...)
  call s:ensure_index()
  let path_regex = a:0 ? a:1 : '.*'
  let successfully_went_to_file = 0
  if a:attempt_file_first
    let successfully_went_to_file = s:go_to_file(path_regex)
  endif
  if successfully_went_to_file == 0
    call s:go_to_annotation(a:annotation_type, path_regex)
  elseif successfully_went_to_file == -1
    let ref = s:get_ref()
    echo 'Cannot find related ' . tolower(a:annotation_type) . ' for [' . ref['handle'] . '].'
  endif
endfunction

" Go to related plugin definition
function! sourcery#go_to_related_plugin_definition()
  call s:ensure_index()
  let ref = s:get_ref()
  let error = 'Cannot find related plugin definition for [' . ref['handle'] . '].'
  let flipped_bindings = s:flipped_plugin_bindings()
  if has_key(flipped_bindings, ref['handle'])
    let plugin = flipped_bindings[ref['handle']]
  else
    echo error
    return
  endif
  let matches = filter(copy(s:plugin_definitions_index), "v:val['plugin'] == '" . plugin . "'")
  if len(matches) > 0
    let match = matches[0]
  else
    echo error
    return
  endif
  echo ''
  silent execute 'edit +' . match['line_number'] match['file']
endfunction

function! s:go_to_file(...)
  call s:ensure_index()
  let path_regex = a:0 ? a:1 : '.*'
  let ref = s:get_ref()
  let tracked_files = {}
  if ref['handle'] == expand('%:t:r') && ref['type'] == 'config'
    return -1
  endif
  let files = s:filter_files_by_path(s:get_files_from_paths(g:sourcery#tracked_paths), path_regex)
  for file in files
    let tracked_files[fnamemodify(file, ':t:r')] = file
  endfor
  if has_key(tracked_files, ref['handle']) && filereadable(tracked_files[ref['handle']])
    echo ''
    silent execute 'edit' tracked_files[ref['handle']]
    return 1
  endif
  return 0
endfunction

function! s:go_to_annotation(type, path_regex)
  let ref = s:get_ref()
  let error = 'Cannot find related ' . tolower(a:type) . ' for [' . ref['handle'] . '].'
  let handle = ref['handle']
  let index = s:filter_index_by_path(s:annotations_index, a:path_regex)
  let matches = filter(index, "v:val['type'] == '" . a:type . "' && v:val['handle'] == '" . handle . "'")
  if len(matches) > 0
    let match = matches[0]
    echo ''
    silent execute 'edit +' . match['line_number'] match['file']
  else
    echo error
  endif
endfunction

function! s:get_ref()
  let plugin_match = matchlist(getline('.'), g:sourcery#plugin_definition_regex)
  if len(plugin_match) > 0
    return s:get_ref_from_plug_definition(plugin_match[3])
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
    \ 'handle': s:plugin_bindings[a:plugin]
    \ }
endfunction

function! s:get_ref_from_paragraph_annotation()
  silent normal "lyip
  let paragraph = @l
  let lines = split(paragraph, '\n')
  for line in lines
    let ref_match = matchlist(line, g:sourcery#annotation_regex)
    if empty(ref_match) == 0
      return {'type': tolower(ref_match[1]), 'handle': ref_match[2]}
    endif
  endfor
  return {'type': 'n/a', 'handle': 'n/a'}
endfunction

function! s:get_ref_for_current_config_file()
  return {'type': 'config', 'handle': expand('%:t:r')}
endfunction


" ------------------------------------------------------------------------------
" # Debugging
" ------------------------------------------------------------------------------

function! sourcery#debug(verbose)
  call s:ensure_index()
  call s:debug_sourced_files(a:verbose)
  " call s:debug_tracked_files(a:verbose)
  call s:debug_indexed_plugins(a:verbose)
  call s:debug_indexed_annotations(a:verbose)
endfunction

function! s:debug_sourced_files(verbose)
  echo "\nSourced Files:\n---"
  for file in s:sourced_files
    echo file
  endfor
endfunction

function! s:debug_tracked_files(verbose)
  echo "\nTracked Files (DEPRECATED):\n---"
  let sourced_files = s:get_files_from_paths(g:sourcery#sourced_paths)
  let deferred_files = s:get_files_from_paths(g:sourcery#deferred_source_paths)
  let sourced_and_deferred_files = []
  for file in s:get_files_from_paths(g:sourcery#tracked_paths)
    let sourced_and_deferred = index(sourced_files, file) >= 0 && index(deferred_files, file) >= 0
    let sourced = index(sourced_files, file) >= 0
    let nvim_only = fnamemodify(file, ':e') == 'lua' && !has('nvim')
    let disabled = s:should_source_file(file) == 0
    let status = ''
    if nvim_only
      let status = '--- DISABLED (lua not supported)'
    elseif disabled
      let status = '--- DISABLED'
    elseif sourced_and_deferred
      call add(sourced_and_deferred_files, file)
      break
    elseif sourced
      let status = '--- sourced'
    endif
    echo file status
  endfor
  for file in sourced_and_deferred_files
    echo file '--- sourced (deferred)'
  endfor
endfunction

function! s:debug_indexed_plugins(verbose)
  echo "\nIndexed Plugins:\n---"
  for index in s:plugin_definitions_index
    let verbose = a:verbose ? ' --- ' . index['line'] : ''
    echo index['file'] . ':' . index['line_number'] '---' index['plugin'] '=>' s:plugin_bindings[index['plugin']] . verbose
  endfor
endfunction

function! s:debug_indexed_annotations(verbose)
  echo "\nIndexed Annotations:\n---"
  for index in s:annotations_index
    let verbose = a:verbose ? ' --- ' . index['line'] : ''
    echo index['file'] . ':' . index['line_number'] '---' substitute(index['type'], '^.', '\u&', '') . ':' index['handle'] . verbose
  endfor
endfunction
