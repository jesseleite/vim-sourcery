## Warning!

__*This package is still in early development, there may be bugs and breaking changes!*__ 💥 💥 💥

---

# Vim Sourcery 🧙‍♂️

A Vim plugin to help users organize and navigate their `.vimrc` configs.

- [Rationale](#rationale)
- [Video Demonstration](#video-demonstration)
- [Installation](#installation)
- [File Structure Conventions](#file-structure-conventions)
- [Jumping Between Files](#jumping-between-files)
- [Sourcing & Tracking](#sourcing--tracking)
- [Auto-Sourcing](#auto-sourcing)
- [Path Helpers](#path-helpers)

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

### Separate files with Sourcery

| | Pros & Cons |
| :- | :- |
| 💚 | Simple installation |
| 💚 | More organized |
| 💚 | Smaller files |
| 💚 | Every new file is automatically sourced |
| 💚 | Conventional structure makes it easy to manage as your config grows |
| 💚 | Easily jump between related plugin definitions, mappings, and configs |

## Video Demonstration

Coming soon!

## Installation

1. Install using [vim-plug](https://github.com/junegunn/vim-plug) or similar:

    ```vim
    Plug 'jesseleite/vim-sourcery'
    ```

2. If you want Sourcery to help scaffold a [sensible file structure](#file-structure-conventions), run the `:SourceryScaffold` command.

3. If you are using [vim-plug](https://github.com/junegunn/vim-plug) or similar, you might consider moving your plugin definitions into `plugins.vim`.

4. Initialize Sourcery after you source your plugins.

    ```vim
    call plug#begin('~/.vim/plugged')
      source ~/.dotfiles/vim/plugins.vim
    call plug#end()

    call sourcery#init()
    ```

5. Add the Sourcery mappings:

    ```vim
    function! SourceryMappings()
      nmap <buffer> gp <Plug>SourceryGoToRelatedPluginDefinition
      nmap <buffer> gm <Plug>SourceryGoToRelatedMappings
      nmap <buffer> gc <Plug>SourceryGoToRelatedConfig
    endfunction
    ```

6. Order pizza! 🍕 🤘 😎

## File Structure Conventions

Two file structure conventions are automatically detected, sourced, and tracked for [jump mappings](#jumping-between-files) and auto-sourcing on save.

1. The first is based on your standard system vimfiles path. Depending on your OS, this should be in `$HOME/.vim` or `$HOME/vimfiles`. Sourcery will source and/or track the following by default:

    ```
    ~/.vim
    ├── $MYVIMRC             // Your .vimrc, wherever it is located
    ├── plugins.vim          // A plugin manager definitions file will be sourced and tracked
    ├── mappings.vim         // A mappings file will be sourced and tracked
    ├── plugin               // All files within the following folders will be tracked as well
    ├── autoload
    └── after
    ```

2. If you prefer to keep your vim configuration in an external dotfiles repo for easy version control, a common practice is to symlink your `.vimrc` to your `$HOME` folder. Sourcery will take care of sourcing and tracking the following, relative to your `.vimrc` within your dotfiles:

    ```
    ~/.dotfiles
    └── vim
        ├── vimrc            // Symlink your .vimrc to this file
        ├── plugins.vim      // A plugin manager definitions file will be sourced and tracked
        ├── mappings.vim     // A mappings file will be sourced and tracked
        └── config           // All files within this folder will be sourced and tracked as well
            ├── sanity.vim
            ├── theme.vim
            ├── fugitive.vim
            └── fzf.vim
    ```

    Sourcery should be able to follow your `.vimrc` symlink to find your vim dotfiles, but you can explicitly define the path by setting the following:

    ```vim
    let g:sourcery#vim_dotfiles_path = '~/.dotfiles/vim'
    ```

    > _**Tip:** If you want Sourcery to help scaffold example files based on these conventions, run the `:SourceryScaffold` command!_

## Jumping Between Files

The best part about Sourcery is the jump mappings. These let you jump between related plugin definition, mappings, and configs, no matter where they are in your vim dotfiles. To do this, Sourcery uses a set of annotation conventions to setup your jump points. Imagine you have the following pieces of code somewhere in your .vimrc:

### Plugin Definitions

Plugins sourced via `packadd`, [vim-plug](https://github.com/junegunn/vim-plug), and [vundle.vim](https://github.com/VundleVim/Vundle.vim) are supported and indexed out-of-the-box:

```vim
Plug 'junegunn/fzf.vim'
```

By default, Sourcery will take the last segment of the plugin repository or path and use that as the handle. It will also ignore common prefixes and suffixes (`vim-`, `nvim-`, `-vim`, `-nvim`, `.vim`, `.nvim`) to create a cleaner handle.

In the above example, `fzf` will be the handle we'll need to use for our jump point annotations. If you want to customize a handle, you can explicitly set a plugin annotation binding:

```vim
let g:sourcery#explicit_plugin_bindings = {
  \ 'fzf.vim': 'some-other-handle',
  \ }
```

### Mappings Annotations

Let's say you have a set of related mappings for a plugin like [fzf.vim](https://github.com/junegunn/fzf.vim). To setup a jump point to a related set of mappings, add the `" Mappings: <handle>` annotation above those mappings:

```vim
" Mappings: fzf
nmap <Leader>f :GFiles<CR>
nmap <Leader>F :Files<CR>
nmap <Leader>h :History<CR>
nmap <Leader>H :Helptags<CR>
```

### Config Annotations:

The same applies for a related set of config and/or settings. To setup a jump point to a related set of config, add the `" Config: <handle>` annotation above that config:

```vim
" Config: fzf
let g:fzf_history_dir = '~/.vim/fzf_history'
let g:fzf_preview_window = 'right:50%:noborder:hidden'
```

### Dedicated Config Files:

If you have a lot of config for a specific thing, you can create a separate `<handle>.vim` config file in the `plugin` or `config` directory (depending on your chosen [file structure](#file-structure-conventions)). For our fzf plugin examples above, we would create an `fzf.vim` config file for all of our fzf-related config and settings.

### Jump Mappings

Once you have the above annotations setup, you can use the provided jump mappings to jump between related plugin definitions, mappings, and configs 🔥

```vim
function! SourceryMappings()
  nmap <buffer> gp <Plug>SourceryGoToRelatedPluginDefinition
  nmap <buffer> gm <Plug>SourceryGoToRelatedMappings
  nmap <buffer> gc <Plug>SourceryGoToRelatedConfig
endfunction
```

## Sourcing & Tracking

The best part about Sourcery is the sourcing & tracking. Sourcery really isn't sorcery, it's just good old fashioned Sourcery. Let's take a look at what `sourcery#init()` does out-of-the-box:

### Sourcing

By default, Vim will automatically source your .vimrc (wherever it is located, see `:help vimrc`), as well as files within `autoload`, `plugin`, `after`, etc. within your system vimfiles directory (see `:help vimfiles`).

On top of the files Vim sources for you, Sourcery will also source `plugins.vim` and `mappings.vim` files, and if you've chosen an external dotfiles repo (see [file structure conventions](#file-structure-conventions)), any files added to `config` will also be sourced.

> _**Note:** The `plugins.vim`, `mappings.vim`, and `config` paths are totally optional. Feel free to delete them if they don't suit your fancy!_

If you have extra `*.vim` files or folders you wish to source, you can source them before you initialize Sourcery:

```vim
call sourcery#source_path('custom-file.vim')
call sourcery#source_path('custom-config-folder')
call sourcery#init()
```

> _**Note:** You can pass both absolute and relative paths to `sourcery#source_path()`._

### Tracking

When files are sourced, they are also tracked for Sourcery's [jump mappings](#jumping-between-files) and [auto-sourcing](#auto-sourcing). If you wish to track a path without sourcing it, you can do this before initializing Sourcery:

```vim
call sourcery#track_path('custom-file.vim')
call sourcery#track_path('custom-config-folder')
call sourcery#init()
```

> _**Note:** You can pass both absolute and relative paths to `sourcery#track_path()`._

## Auto-Sourcing

The best part about Sourcery is the auto-sourcing. Sourcery attempts to re-source your whole vim config when saving any of your sourced or tracked files. This kind of thing is easy when you have a single `.vimrc` file, but it can get more complicated to setup when you split everything out into multiple files. Sourcery does all of this for you, so that it's easier to test out changes in your vimscript without having to restart Vim.

> _**Note:** That said, sometimes you need to restart Vim anyway, like when removing variables, etc. For example, if Vim has sourced a variable and you remove it, the value may remain in memory until you restart Vim._

## Path Helpers

The best part about Sourcery is the path helpers. After Sourcery has been loaded, you can use these helper functions anywhere in your vim configs to easily get absolute paths to the things you love most:

### Vim Dotfiles Path

Get path relative to your dotfiles (see [file structure conventions](#file-structure-conventions)):

```vim
sourcery#vim_dotfiles_path('config/sushi.vim')
```

### System Vimfiles Path

Get path relative to your system vimfiles (see `:help vimfiles`):

```vim
sourcery#system_vimfiles_path('plugin/sushi.vim')
```

## TODO

The best part about Sourcery is what is not yet finished:

- Record quick video demo
- Write proper vim help file
- Order pizza
