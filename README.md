# Vim Sourcery 🧙‍♂️

A Vim plugin to help users organize and navigate their `.vimrc` / `init.vim` configs.

- [Rationale](#rationale)
- [Video Demonstration](#video-demonstration)
- [Installation](#installation)
- [File Structure Conventions](#file-structure-conventions)
- [Jumping Between Files](#jumping-between-files)
- [Telescope Finder](#telescope-finder)
- [Sourcing & Tracking](#sourcing--tracking)
- [Auto-Sourcing](#auto-sourcing)
- [Path Helpers](#path-helpers)

## Rationale

Most Vim users start out with a single `.vimrc` / `init.vim` file. As that file becomes large and unruly, it becomes desirable to split into multiple vim config files. However, each approach has pros and cons...

### Single file

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

> Less boring video incoming 😴

> But until then...

[![thumbnail-play-icon-320x180](https://user-images.githubusercontent.com/5187394/109403315-785ed400-792a-11eb-8618-2b150b1bcc11.png)](https://youtu.be/_LZAflGsPuI)

## Installation

1. Install using [vim-plug](https://github.com/junegunn/vim-plug) or similar:

    ```vim
    Plug 'jesseleite/vim-sourcery'
    ```

2. If you want Sourcery to help scaffold a [sensible file structure](#file-structure-conventions), run the `:SourceryScaffold` command.

3. If you are using [vim-plug](https://github.com/junegunn/vim-plug) or similar, you might consider moving your plugin definitions into `plugins.vim`.

4. Initialize Sourcery after you source your plugins.

    ```vim
    call plug#begin()
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

### Standard Config Location

The first is based on your standard system vimfiles path. Depending on your OS and Vim distribution, this should be in `$HOME/.vim`, `$HOME/.config/nvim`, or `$HOME/vimfiles`. Sourcery will source and/or track the following by default:

```
~/.vim
├── $MYVIMRC               // Your .vimrc / init.vim, wherever it is located
├── plugins.vim            // A plugin manager definitions file will be sourced & tracked
├── mappings.vim           // A mappings file will be sourced & tracked
├── plugin                 // All files within the following folders will be tracked as well
├── autoload
├── after
└── lua
```

> _**Tip:** This is what is sourced and tracked by default. Feel free to delete `plugins.vim` and/or `mappings.vim` if you prefer to organize that stuff in a different location. You may also [source & track as many extra paths](#sourcing--tracking) as you see fit. The world is your oyster!_

### Custom External Location

If you prefer a more custom config structure in an external location, a common practice is to symlink your `~/.vimrc` / `~/.config/nvim/init.vim` to your custom dotfiles location. Sourcery will source and/or track the following by default, relative to the `.vimrc` / `init.vim` within your dotfiles:

```
~/.dotfiles
└── vim
    ├── $MYVIMRC           // Symlink your .vimrc / init.vim to this file
    ├── plugins.vim        // A plugin manager definitions file will be sourced & tracked
    ├── mappings.vim       // A mappings file will be sourced & tracked
    └── config             // All files within this folder will be sourced & tracked as well
        ├── sanity.vim
        ├── theme.vim
        └── telescope.lua
```

Sourcery should be able to follow the `.vimrc` / `init.vim` symlink to find your vim dotfiles, but you can explicitly define the path by setting the following before your call to `sourcery#init()`:

```vim
let g:sourcery#vim_dotfiles_path = '~/.dotfiles/vim'
```

> _**Tip:** Again, you may customize the above structure however you see fit! Just be sure to [source & track any custom paths](#sourcing--tracking) you wish to configure._

### Scaffolding Files

If you want Sourcery to help scaffold example files for either of the above conventions, run the `:SourceryScaffold` command!

## Jumping Between Files

The best part about Sourcery is the jump mappings. These let you jump between related plugin definition, mappings, and configs, no matter where they are in your vim dotfiles. To do this, Sourcery uses a set of annotation conventions to setup your jump points. Imagine you have the following pieces of code somewhere in your config:

### Plugin Definitions

Plugins sourced via `packadd`, [vim-plug](https://github.com/junegunn/vim-plug), and [vundle.vim](https://github.com/VundleVim/Vundle.vim) are supported and indexed out-of-the-box:

```vim
Plug 'nvim-telescope/telescope.nvim'
```

By default, Sourcery will take the last segment of the plugin repository or path and use that as the handle. It will also ignore common prefixes and suffixes (`vim-`, `nvim-`, `-vim`, `-nvim`, `.vim`, `.nvim`) to create a cleaner handle.

In the above example, `telescope` will be the handle we'll need to use for our jump point annotations. If you want to customize a handle, you can explicitly set a plugin annotation binding:

```vim
let g:sourcery#explicit_plugin_bindings = {
  \ 'nvim-telescope/telescope.nvim': 'telescopic-johnson',
  \ }
```

### Mappings Annotations

Let's say you have a set of related mappings for a plugin like [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim). To setup a jump point to a related set of mappings, add the `" Mappings: <handle>` annotation above those mappings:

```vim
" Mappings: telescope
nmap <Leader>f :Telescope find_files<CR>
nmap <Leader>/ :Telescope live_grep<CR>
nmap <Leader>b :Telescope buffers<CR>
nmap <Leader>h :Telescope help_tags<CR>
```

> _**Note:** If within a .lua file, you can use a lua comment like `-- Mappings: telescope` to annotate mappings._

### Config Annotations:

The same applies for a related set of config and/or settings. To setup a jump point to a related set of config, add the `" Config: <handle>` annotation above that config:

```vim
" Config: sourcery
let g:sourcery#disable_sourcing_on_boot = 0
let g:sourcery#disable_autosourcing_on_save = 0
```

> _**Note:** If within a .lua file, you can use a lua comment like `-- Config: sourcery` to annotate config._

### Dedicated Config Files:

If you have a lot of config for a specific thing, you can create a separate `<handle>.vim` or `<handle>.lua` config file in any of your [sourced](#sourcing) or [tracked](#tracking) directories.

### Jump Mappings

Once you have the above annotations setup, you can use the provided jump mappings to jump between related plugin definitions, mappings, and configs 🔥

```vim
function! SourceryMappings()
  nmap <buffer> gp <Plug>SourceryGoToRelatedPluginDefinition
  nmap <buffer> gm <Plug>SourceryGoToRelatedMappings
  nmap <buffer> gc <Plug>SourceryGoToRelatedConfig
endfunction
```

### Setting Up Custom Annotations

Maybe you want to setup a custom annotation and jump mapping for something other than config and mappings. For example, maybe you have a set of related highlight customizations. Here is how you would go about adding custom annotation types:

1. Define an explicit annotation types list before calling `sourcery#init()`, so that Sourcery knows which annotations to index:

    ```vim
    let g:sourcery#annotation_types = [
      \ 'Mappings',
      \ 'Config',
      \ 'Highlights',
      \ ]
    ```

2. Add a mapping for jumping to your new annotation to your `SourceryMappings()` function:

    ```vim
    nmap <silent><buffer> gh :SourceryGoToRelatedAnnotation Highlights<CR>
    ```

    > _**Note:** If you call this command with a `!` bang modifier, Sourcery will attempt to find a related file before looking for a related annotation, similar to how Sourcery handles going to related config files and annotations. You may also pass a second path regex argument to scope where Sourcery will look for your file and/or annotation._

3. You should now be able to jump to your custom annotation!

    ```vim
    " Highlights: telescope
    highlight TelescopeBorder ctermfg=darkgrey
    highlight TelescopePromptBorder ctermfg=darkgrey
    highlight TelescopeResultsBorder ctermfg=darkgrey
    highlight TelescopePreviewBorder ctermfg=darkgrey
    ```

## Telescope Finder

The best part about Sourcery is the [Telescope](https://github.com/nvim-telescope/telescope.nvim) finder. This lets you magically fuzzy find any of your vim config files or [annotations](#mappings-annotations) from any project. Assuming you have Telescope installed:

1. Load the sourcery extension:

    ```lua
    require('telescope').load_extension('sourcery')
    ```

2. Open the sourcery finder `:Telescope sourcery`!

## Sourcing & Tracking

The best part about Sourcery is the sourcing & tracking. Sourcery really isn't sorcery, it's just good old fashioned Sourcery. Let's take a look at what `sourcery#init()` does out-of-the-box:

### Sourcing

By default, Vim will automatically source your `.vimrc` / `init.vim` (wherever it is located, see `:help vimrc`), as well as files within `autoload`, `plugin`, `after`, etc. within your system vimfiles directory (see `:help vimfiles`).

On top of the files Vim sources for you, Sourcery will also source `plugins.vim` and `mappings.vim` files, and if you've chosen an external dotfiles repo (see [file structure conventions](#file-structure-conventions)), any files added to a `config` folder will also be sourced.

> _**Note:** The `plugins.vim`, `mappings.vim`, and `config` paths are totally optional. Feel free to delete them if they don't suit your fancy!_

If you have extra `*.vim` / `*.lua` files or folders you wish to source, you can source them before you initialize Sourcery:

```vim
call sourcery#source_path('custom-file.vim')
call sourcery#source_path('custom-file.lua')
call sourcery#source_path('custom-config-folder')
call sourcery#init()
```

> _**Note:** You can pass both absolute and relative paths to `sourcery#source_path()`._

### Tracking

When files are sourced, they are also tracked for Sourcery's [jump mappings](#jumping-between-files) and [auto-sourcing](#auto-sourcing). If you don't want Sourcery to handle the sourcing of a file or folder, it is recommended you still track it before initializing Sourcery:

```vim
call sourcery#track_path('custom-file.vim')
call sourcery#track_path('custom-file.lua')
call sourcery#track_path('custom-config-folder')
call sourcery#init()
```

> _**Note:** You can pass both absolute and relative paths to `sourcery#track_path()`._

## Auto-Sourcing

The best part about Sourcery is the auto-sourcing. Sourcery attempts to re-source your whole vim config when saving any of your sourced or tracked files. This kind of thing is easy when you have a single `.vimrc` / `init.vim` file, but it can get more complicated to setup when you split everything out into multiple files. Sourcery does all of this for you, so that it's easier to test out changes in your vimscript without having to restart Vim.

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

- Record less boring video
- If there are multiple matching files or annotations, cycle between them
- Support packer.nvim
- Write proper vim help file
- Order pizza
