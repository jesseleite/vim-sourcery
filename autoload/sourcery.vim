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
  " augroup sourcery_autosource
  "   autocmd!
  "   execute 'autocmd BufWritePost' join(g:sourcery#autosource_paths, ',') 'nested source' $MYVIMRC
  " augroup END
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
  echo s:stub_path
  echo globpath(s:stub_path, '**', 0, 1)
  " let files = []
  " for file in globpath(s:stub_path, '**', 0, 1)
  "   if isdirectory(file) == 0
  "     call add(files, substitute(file, s:stub_path . '/', '', ''))
  "   endif
  " endfor
  " return files
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

" Go to related plugin definition
function! sourcery#go_to_related_plugin_definition()
  let error = 'Cannot find it Timmy.'
  let ref = s:get_ref()
  let flipped_bindings = s:flip_dictionary(s:plugin_bindings)
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

" Go to related mappings
function! sourcery#go_to_related_mappings()
  call s:go_to_annotation('mappings')
endfunction


" Go to related config
function! sourcery#go_to_related_config()
  " TODO: attempt config file first, otherwise fall back to annotation
  call s:go_to_annotation('config')
  " let ref = s:get_ref()
  " let plugin = s:get_plugin_from_ref(ref)
  " let path = sourcery#vim_dotfiles_path(ref['type'] . '-config/' . ref['slug'] . '.vim')
  " let current_file = fnamemodify(@%, ':p')
  " if path == current_file
  "   echo 'Already in config for' plugin . '.'
  " endif
  " if filereadable(path)
  "   silent execute 'edit ' . path
  " elseif ref['type'] == 'plugin'
  "   call s:go_to_ref(ref, 'plugins.vim', 'config')
  " elseif ref['type'] == 'local'
  "   " TODO: Find reliable way to search for ref in vimrc file
  "   call s:go_to_ref(ref, 'vimrc', 'config')
  " else
  "   echo 'Ref not found.'
  " endif
endfunction

function! s:go_to_annotation(type)
  let error = 'Cannot find it Jose.'
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
  let plugin_match = matchlist(getline('.'), g:sourcery#plugin_definition_regex)
  if len(plugin_match) > 0
    return s:get_ref_from_plug_definition(plugin_match[1])
  else
    return s:get_ref_from_paragraph_annotation()
  else
    return s:get_ref_for_current_config_file()
  endif
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
    let ref = matchlist(line, '"\s*\(.*\): \(.*\)')
    if empty(ref) == 0
      return {'type': tolower(ref[1]), 'slug': ref[2]}
    endif
  endfor
  return {'type': 'n/a', 'slug': 'n/a'}
endfunction

function! s:get_ref_for_current_config_file()
  return {'type': 'config', 'slug': expand('%:t:r')}
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

" ---

if exists('g:sourcery#tracked_paths') == 0
  let g:sourcery#tracked_paths = [
    \ $MYVIMRC,
    \ resolve($MYVIMRC),
    \ sourcery#vim_dotfiles_path('test.vim'),
    \ ]
endif

" \ resolve($MYVIMRC),
" \ sourcery#system_vimfiles_path('autoload'),
" \ sourcery#system_vimfiles_path('plugin'),
" \ sourcery#vim_dotfiles_path('mappings.vim'),
" \ sourcery#vim_dotfiles_path('plugins.vim'),
" \ sourcery#vim_dotfiles_path('local-config'),
" \ sourcery#vim_dotfiles_path('plugin-config'),


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

if exists('s:plugin_definitions_index') == 0
  let s:plugin_definitions_index = []
endif

if exists('s:annotations_index') == 0
  let s:annotations_index = []
endif

if exists('s:plugin_bindings') == 0
  let s:plugin_bindings = {}
endif

function! sourcery#index()
  for file in s:tracked_files()
    call s:index_annotations(file)
    call s:index_plugin_definitions(file)
  endfor
  call s:merge_plugin_bindings()
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
    let matches = matchlist(line, a:regex)
    if len(matches) > 2
      if a:type == 'plugin'
        call add(index, {'line_number': line_number, 'file': a:file, 'type': 'plugin', 'plugin': matches[1]})
      else
        call add(index, {'line_number': line_number, 'file': a:file, 'type': tolower(matches[1]), 'slug': matches[2]})
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

" --

function! sourcery#get_index()
  echo s:plugin_definitions_index
  echo s:annotations_index
endfunction
