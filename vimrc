filetype plugin indent off

if &compatible
  set nocompatible
endif

set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

call dein#begin(expand('~/.vim/dein'))

call dein#add('morhetz/gruvbox')
call dein#add('itchyny/lightline.vim')
call dein#add('fatih/vim-go')
call dein#add('vim-jp/vim-go-extra')
call dein#add('scrooloose/syntastic')
call dein#add('nsf/gocode', {'rtp': 'nvim/'})
"call dein#add('petdance/vim-perl')
call dein#add('tpope/vim-fugitive')
call dein#add('soramugi/auto-ctags.vim')
"call dein#add('hotchpotch/perldoc-vim')
"call dein#add('Shougo/neocomplcache')
"call dein#add('Shougo/neosnippet')
"call dein#add('Shougo/neosnippet-snippets')
"call dein#add('thinca/vim-quickrun')
"call dein#add('mattn/emmet-vim')
"call dein#add('pangloss/vim-javascript')
"call dein#add('othree/html5.vim')
"call dein#add('hail2u/vim-css3-syntax')
"call dein#add('jelera/vim-javascript-syntax')
"call dein#add('hokaccha/vim-html5validator')

call dein#end()

" Required:
filetype plugin indent on

" 大文字小文字のみの場合大文字小文字を無視
set ignorecase
" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase
" インクリメンタルサーチ
set incsearch
" 検索ハイライト
set hlsearch
" 選択範囲をクリップボードにコピー
set clipboard+=unnamed

"---------------------------------------------------------------------------
" 編集に関する設定:
"
" タブの画面上での幅
set tabstop=4
" 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set softtabstop=4
" 自動インデントでずれる幅
set shiftwidth=4
" タブをスペースに展開する/ しない (expandtab:展開する)
set expandtab
" 自動的にインデントする (noautoindent:インデントしない)
set autoindent
" バックスペースでインデントや改行を削除できるようにする
set backspace=indent,eol,start
" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set wrapscan
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch
" コマンドライン補完するときに強化されたものを使う(参照 :help wildmenu)
set wildmenu
" テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions+=mM
" インデントの深さによって折りたたむ
set foldmethod=indent
set foldlevel=4
set foldcolumn=3
"---------------------------------------------------------------------------
" GUI固有ではない画面表示の設定:
"
" タイトルを表示する
set title
" 行番号を表示 (nonumber:非表示)
set number
" ルーラーを表示 (noruler:非表示)
set ruler
" タブや改行を表示 (list:表示)
set list
" どの文字でタブや改行を表示するかを設定
" set listchars=tab:>-,extends:<,trail:-,eol:<
set listchars=tab:>.,trail:_,eol:↲,extends:>,precedes:<,nbsp:%
" 全角スペースをハイライト
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme       * call ZenkakuSpace()
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif
" 長い行を折り返して表示 (nowrap:折り返さない)
set wrap
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" コマンドラインの高さ
set cmdheight=2
" コマンドをステータス行に表示
set showcmd
" モードを表示する
"set showmode
" 画面のカラースキーマ
set background=dark
" ターミナルの背景を適応する
autocmd ColorScheme * highlight Normal ctermbg=none
autocmd ColorScheme * highlight LineNr ctermbg=none
" colorscheme molokai
colorscheme gruvbox
" シンタックスハイライト
syntax on
" screen 256色対応
set t_Co=256

"---------------------------------------------------------------------------
" ファイル操作に関する設定:
"
" バックアップファイルを作成しない
set nobackup
" スワップファイルを作成しない
" set noswapfile

"---------------------------------------------------------------------------
" キーバインド
"
"nnoremap    [unite]   <nop>
"nmap        ,         [unite]
"nnoremap <silent> [unite]b :<C-u>Unite<space>buffer<CR>
"nnoremap <silent> [unite]f :<C-u>Unite<space>file<CR>

"---------------------------------------------------------------------------
" プラグインに関する設定:
"
" colorschemeの設定
let g:gruvbox_contrast_dark='hard'
let g:gruvbox_termcolors = 256
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'filename' ] ]
      \ },
      \ 'component_function': {
      \   'readonly': 'LightlineReadonly',
      \   'modified': 'LightlineModified',
      \   'fugitive': 'LightlineFugitive',
      \   'filename': 'LightlineFilename'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }

function! LightlineModified()
  if &filetype == 'help'
    return ''
  elseif &modified
    return '+'
  elseif &modifiable
    return ''
  else
    return '-'
  endif
endfunction

function! LightlineReadonly()
  if &filetype == 'help'
    return ''
  elseif &readonly
    return 'x'
  else
    return ''
  endif
endfunction

function! LightlineFugitive()
  return exists('*fugitive#head') ? fugitive#head() : ''
endfunction

function! LightlineFilename()
  return ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
       \ ('' != expand('%:t') ? expand('%:t') : '[No Name]') .
       \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

let g:lightline.tab = {
      \ 'active': [ 'tabnum', 'filename', 'modified' ],
      \ 'inactive': [ 'tabnum', 'filename', 'modified' ]
      \ }

let g:lightline.tab_component_function = {
      \ 'filename': 'LightlineTabFilename',
      \ 'modified': 'lightline#tab#modified',
      \ 'readonly': 'lightline#tab#readonly',
      \ 'tabnum': 'lightline#tab#tabnum' }

function! LightlineTabFilename(n) abort
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let _ = pathshorten(expand('#'.buflist[winnr - 1].':f'))
  return _ !=# '' ? _ : '[No Name]'
endfunction

" 常にtabを表示
set showtabline=2
set tabline=%!MyTabLine()
hi Normal ctermfg=white

" Perl のための設定
autocmd BufNewFile,BufRead *.psgi   set filetype=perl
autocmd BufNewFile,BufRead *.t      set filetype=perl
autocmd BufNewFile,BufRead *.pm     set filetype=perl
autocmd BufNewFile,BUfRead *.tt     set filetype=html

" go-linterとsyntasticの設定 goのチェック
let g:syntastic_mode_map = { 'mode': 'passive',
    \ 'active_filetypes': ['go'] }
let g:syntastic_go_checkers = ['go', 'golint']

" Go言語設定
let g:go_fmt_command = "goimports"
let g:go_auto_sameids = 1
let g:go_gocode_unimported_packages = 1
let g:go_version_warning = 0


"ctags設定
set tags+=.git/tags
autocmd BufWritePost *
      \ if exists('b:git_dir') && executable(b:git_dir.'/hooks/ctags') |
      \   call system('"'.b:git_dir.'/hooks/ctags" &') |
      \ endif

nnoremap <F3> :<C-u>tab stj <C-R>=expand('<cword>')<CR><CR>
nnoremap <C-]> g<C-]>
