" Commands
command!          SourceryScaffold                     call sourcery#scaffold()
command!          SourceryGoToRelatedPluginDefinition  call sourcery#go_to_related_plugin_definition()
command!          SourceryGoToRelatedMappings          call sourcery#go_to_related_mappings()
command!          SourceryGoToRelatedConfig            call sourcery#go_to_related_config()
command! -nargs=1 SourceryGoToRelatedAnnotation        call sourcery#go_to_related_annotation(<q-args>)
command! -bang    SourceryDebug                        call sourcery#debug(<bang>0)

" Mappings
nnoremap <silent> <Plug>SourceryGoToRelatedPluginDefinition  :SourceryGoToRelatedPluginDefinition<CR>
nnoremap <silent> <Plug>SourceryGoToRelatedMappings          :SourceryGoToRelatedMappings<CR>
nnoremap <silent> <Plug>SourceryGoToRelatedConfig            :SourceryGoToRelatedConfig<CR>
