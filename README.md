# Vim Sourcery 🧙‍♂️

A Vim plugin to help users organize their vimrc configs.

- [Rationale](#rationale)
- [Video Demonstration](#video-demonstration)
- [Installation](#installation)
- [File Structure Conventions](#file-structure-conventions)
- [Jumping Between Files](#jumping-between-files)

## Rationale

Most Vim users start out with a single .vimrc file. As that file becomes large and unruly, it becomes desirable to split into multiple vim config files. However, each approach has pros and cons...

### Single .vimrc file

| | Pros & Cons |
| :- | :- |
| 💚 | Simple setup |
| 💚 | Everything in one place |
| 💔 | Harder to manage as the file grows |

### Separate files for plugin definitions, mappings, and configs

| | Pros & Cons |
| :- | :- |
| 💚 | More organized |
| 💚 | Smaller files |
| 💔 | More work to setup and source every new file |
| 💔 | Jumping between files can become tedious |

### Separate files with Vim Sourcery

| | Pros & Cons |
| :- | :- |
| 💚 | Simple installation |
| 💚 | More organized |
| 💚 | Smaller files |
| 💚 | Every new file is automatically sourced |
| 💚 | Conventional structure makes it easy to manage as your config grows |
| 💚 | Easily jump between related plugin definition, mappings, and configs |

## Video Demonstration

Coming soon!

## Installation

1. Install using [vim-plug](https://github.com/junegunn/vim-plug) or similar:

    ```
    Plug 'jesseleite/vim-sourcery'
    ```

2. Run the `:SourceryScaffold` command to scaffold out the [file structure conventions](#file-structure-conventions) as displayed below.

    > _**Note:** This command isn't implemented yet. Coming soon!_

3. Move your plugin definitions into `plugins.vim`, if you aren't already doing this.

4. Setup your `.vimrc` to source your plugins from `plugins.vim`, then let Vim Sourcery source the rest:

    ```vim
    call plug#begin('~/.vim/plugged')
      source ~/.dotfiles/vim/plugins.vim
    call plug#end()

    call sourcery#source()
    ```

5. Add the following to your `mappings.vim` file:

    ```vim
    function! sourcery#vimrc_mappings()
      nnoremap <buffer><nowait> <leader>gc :SourceryGoToRelatedConfig<CR>
      nnoremap <buffer><nowait> <leader>gm :SourceryGoToRelatedMappings<CR>
      nnoremap <buffer><nowait> <leader>gp :SourceryGoToRelatedPluginDefinition<CR>
    endfunction
    ```

6. Order pizza! 🍕 🤘 😎

## File Structure Conventions

```
~/.dotfiles
└── vim
    ├── vimrc             // Symlink to ~/.vimrc
    ├── plugins.vim       // All your plugin definitions and settings go here
    ├── mappings.vim      // All your mappings go here
    ├── local-config      // Complex local config can optionally be split into files here
    │   ├── sanity.vim
    │   └── theme.vim
    └── plugin-config     // Complex plugin config can optionally be split into files here
        ├── fugitive.vim
        └── fzf.vim
```

## Jumping Between Files

Coming soon!

## TODO

- Finish scaffold command
- Add mappings
- Record quick video demo
