## Warning!

__*This package is still in early development, there may be bugs and breaking changes!*__ 💥 💥 💥

---

# Vim Sourcery 🧙‍♂️

A Vim plugin to help users organize their `.vimrc` configs.

- [Rationale](#rationale)
- [Video Demonstration](#video-demonstration)
- [Installation](#installation)
- [File Structure Conventions](#file-structure-conventions)
- [Jumping Between Files](#jumping-between-files)

## Rationale

Most Vim users start out with a single `.vimrc` file. As that file becomes large and unruly, it becomes desirable to split into multiple vim config files. However, each approach has pros and cons...

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

2. Run the `:SourceryScaffold` command to scaffold out one of the [file structure conventions](#file-structure-conventions).

3. Move your plugin manager definitions into `plugins.vim`, if you aren't already doing this.

4. Setup your `.vimrc` to source your plugins from `plugins.vim`, then initialize Vim Sourcery:

    ```vim
    call plug#begin('~/.vim/plugged')
      source ~/.dotfiles/vim/plugins.vim
    call plug#end()

    call sourcery#init()
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

Two file structure conventions are automatically detected, sourced, and tracked for [jump mappings](#jumping-between-files) and auto-sourcing on save.

1. The first is based on your standard system vimfiles path. Depending on your OS, this should be in `$HOME/.vim` or `$HOME/vimfiles`. Vim Sourcery will source and/or track the following by default:

    ```
    ~/.vim
    ├── $MYVIMRC             // Your .vimrc, wherever it is located
    ├── plugins.vim          // A plugin manager definitions file will be sourced and tracked
    ├── mappings.vim         // A mappings file will be sourced and tracked
    ├── plugin               // All files within the following folders will be tracked as well
    ├── autoload
    └── after
    ```

2. If you prefer to keep your vim configuration in an external dotfiles repo for easy version control, a common practice is to symlink your `.vimrc` to your `$HOME` folder. Vim Sourcery will take care of sourcing and tracking the following, relative to your `.vimrc` within your dotfiles:

    ```
    ~/.dotfiles
    └── vim
        ├── vimrc            // Symlink to ~/.vimrc
        ├── plugins.vim      // A plugin manager definitions file will be sourced and tracked
        ├── mappings.vim     // A mappings file will be sourced and tracked
        └── config           // All files within this folder will be sourced and tracked as well
            ├── sanity.vim
            ├── theme.vim
            ├── fugitive.vim
            └── fzf.vim
    ```

    > _**Tip:** Once you have your `.vimrc` symlinked, you can run `:SourceryScaffold` to generate sample files in your dotfiles repo!_

## Jumping Between Files

Coming soon!

## TODO

- Update stubs and scaffolding
  - Refactor to single `config` folder
  - Disclude `config` folder if scaffolding to system vimfiles path
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
