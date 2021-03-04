" Commands
command!                SourceryScaffold                     call sourcery#scaffold()
command!                SourceryGoToRelatedPluginDefinition  call sourcery#go_to_related_plugin_definition()
command!                SourceryGoToRelatedMappings          call sourcery#go_to_related(0, 'Mappings')
command!                SourceryGoToRelatedConfig            call sourcery#go_to_related(1, 'Config')
command! -bang -nargs=+ SourceryGoToRelatedAnnotation        call sourcery#go_to_related(<bang>0, <f-args>)
command! -bang          SourceryDebug                        call sourcery#debug(<bang>0)

" Mappings
nnoremap <silent> <Plug>SourceryGoToRelatedPluginDefinition  :SourceryGoToRelatedPluginDefinition<CR>
nnoremap <silent> <Plug>SourceryGoToRelatedMappings          :SourceryGoToRelatedMappings<CR>
nnoremap <silent> <Plug>SourceryGoToRelatedConfig            :SourceryGoToRelatedConfig<CR>
