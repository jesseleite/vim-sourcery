# Vim Sourcery 🧙‍♂️

WIP!

## Example Usage

```vim
let g:sourcery#vimrc_path = $HOME . '/.dotfiles/vim'

call plug#begin('~/.vim/plugged')
  execute 'source' g:sourcery#vimrc_path . '/plugins.vim'
call plug#end()

call sourcery#source()
```

## Example Folder Structure

```
vim
├── local-config
│   ├── sanity.vim
│   └── theme.vim
├── plugin-config
│   ├── fzf.vim
│   └── fugitive.vim
├── mappings.vim
├── plugins.vim
└── vimrc
```

## TODO

- Bring in 'go to' mappings (for jumping to config, to mappings, and to plugin definition)
- Add scaffolding command (for creating default folders and sample config files, where non-existent)
