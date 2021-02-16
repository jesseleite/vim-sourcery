" Commands
command! SourceryScaffold call sourcery#scaffold()

" Mappings
nnoremap <silent> <Plug>SourceryGoToRelatedPluginDefinition :call sourcery#go_to_related_plugin_definition()<CR>
nnoremap <silent> <Plug>SourceryGoToRelatedMappings :call sourcery#go_to_related_mappings()<CR>
nnoremap <silent> <Plug>SourceryGoToRelatedConfig :call sourcery#go_to_related_config()<CR>
