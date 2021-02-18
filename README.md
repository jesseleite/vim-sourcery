## Warning!

__*This package is still in early development, breaking changes coming!*__ 💥 💥 💥

---

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
    function! VimrcLocalMappings()
      nmap <buffer> <leader>gc <Plug>SourceryGoToRelatedConfig
      nmap <buffer> <leader>gm <Plug>SourceryGoToRelatedMappings
      nmap <buffer> <leader>gp <Plug>SourceryGoToRelatedPluginDefinition
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
    └── config            // All your complex config can optionally be split into files here
        ├── sanity.vim
        ├── theme.vim
        ├── fugitive.vim
        └── fzf.vim
```

## Jumping Between Files

Coming soon!

## TODO

- Document setting custom system vimfiles path
- Document setting custom vim dotfiles path
- Document initialization functions:
  - `sourcery#init()` explain what is done by default
  - `sourcery#track_path()` track another path for jump mappings and autosourcing
  - `sourcery#source_path()` source and track another path (see above)
- Document path helper functions:
  - `sourcery#system_vimfiles_path()` get path relative to system vimfiles (~/.vim)
  - `sourcery#vim_dotfiles_path()` get path relative to vim dotfiles
- Document jump mappings
- Document annotations
- Document explicit plugin bindings
- Record quick video demo
