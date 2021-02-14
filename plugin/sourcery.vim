" Commands
command! SourceryScaffold call sourcery#scaffold()

" Mappings
nnoremap <Plug>SourceryGoToRelatedPluginDefinition :call sourcery#go_to_related_plugin_definition()<CR>
nnoremap <Plug>SourceryGoToRelatedMappings :call sourcery#go_to_related_mappings()<CR>
nnoremap <Plug>SourceryGoToRelatedConfig :call sourcery#go_to_related_config()<CR>
