## 介绍
该插件可以帮你快速获取代码块中的内容，就像'tpope/vim-surround'插件可以快速选择、修改或删除括号中的内容一样。

## 安装
我更倾向于使用vim-plug( https://github.com/junegunn/vim-plug/ )管理器来安装：
```vim
call plug#begin('~/.vim/bundle')
Plug 'peter-lyr/vim-get-blocks'
call plug#end()
```

## 用法
- `yib`表示复制代码块内的内容，`yab`比`yib`多复制两行。
- `vib`表示选择代码块内的内容，`vab`比`vib`多选择两行。
- `dib`表示删除代码块内的内容，`dab`比`dib`多删除两行。
- `cib`表示修改代码块内的内容，`cab`比`cib`多修改两行。
