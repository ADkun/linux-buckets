

set pastetoggle=<F9>
set nocompatible " 关闭 vi 兼容模式
syntax on " 自动语法高亮
set number " 显示行号
set rnu
set cursorline " 突出显示当前行
set ruler " 打开状态栏标尺
set shiftwidth=4 " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4 " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4 " 设定 tab 长度为 4
set nobackup " 覆盖文件时不备份
set noswapfile
set nowritebackup
set noundofile

set ignorecase smartcase " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
set nowrapscan " 禁止在搜索到文件两端时重新搜索
set incsearch " 输入搜索内容时就显示搜索结果
set hlsearch " 搜索时高亮显示被找到的文本
set noerrorbells " 关闭错误信息响铃
set novisualbell " 关闭使用可视响铃代替呼叫
set t_vb= " 置空错误铃声的终端代码

set magic " 设置魔术
set hidden " 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set guioptions-=T " 隐藏工具栏
set guioptions-=m " 隐藏菜单栏
set smartindent " 开启新行时使用智能自动缩进
set backspace=indent,eol,start
set cmdheight=1 " 设定命令行的行数为 1
set laststatus=2 " 显示状态栏 (默认值为 1, 无法显示状态栏)
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\ 

nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

if has("win32")
set guifont=Inconsolata:h12:cANSI
endif

if has("multi_byte")

set encoding=utf-8
set termencoding=utf-8
set formatoptions+=mM
set fencs=utf-8,gbk

if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
set ambiwidth=double
endif

if has("win32")
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
language messages zh_CN.utf-8
endif
endif

let mapleader=","
nnoremap <leader>zr zR
nnoremap <leader>zo zO
nnoremap <leader>zm :set fdm=indent<Enter>zM
nnoremap <leader>nhl :nohl<enter>
nnoremap <leader>ena :e ++enc=utf-8<enter>
nnoremap <leader>ens :e ++enc=cp936<enter>
nnoremap <leader>nl o<esc>
nnoremap <leader>no O<esc>
nnoremap <leader>sr :set rnu<enter>
nnoremap <leader>snr :set nornu<enter>
nnoremap <leader>sn :set nu<enter>
nnoremap <leader>snn :set nonu<enter>
nnoremap <leader>bn :bn<enter>
nnoremap <leader>bb :bp<enter>
nnoremap <leader>ts :ts<enter>
nnoremap <leader>tn :tn<enter>
nnoremap <leader>tp :tp<enter>
nnoremap <leader>te :term<enter>
nnoremap <leader>wq :wq!<enter>
nnoremap <leader>fq :q<enter>
nnoremap <leader>ww :w!<enter>
nnoremap <leader>l :e<enter>
nnoremap <leader>rs :%s/
nnoremap <leader>cx ggdG
nnoremap <leader>wd :pwd<enter>
nnoremap <leader>bf :buffers<enter>
nnoremap <leader>bu :buffer<space>

set clipboard=unnamed
" set foldclose=all " 设置为自动关闭折叠