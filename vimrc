set encoding=utf-8

syntax on
set number
set ruler
set laststatus=2
set listchars=tab:»\»,eol:¬,space:·,trail:·
set t_Co=256
set showmatch

set backspace=eol,start,indent
set clipboard=unnamed
set mouse=a
set autoread
set nobackup
set nowb
set wildmode=longest:full,full
set ttyfast
set lazyredraw
set splitbelow
set splitright
set noeb vb t_vb=
set autochdir
set hlsearch
set incsearch
set smartcase

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set copyindent
set nowrap

let mapleader=";"
map <silent> <C-L> :set list!<CR>
map <leader>v :vsp<CR>
map <leader>h :sp<CR>
map <silent> <C-L> :set hlsearch!<CR>
map <silent> <S-L> :set list!<CR>
map <silent> <C-N> :set number!<CR>
map <leader>+ :vertical resize -5<CR>
map <leader>- :vertical resize -5<CR>
map <leader>c :set clipboard="unnamed"<CR>
map <leader>t :tabnew<CR>
map <leader>e :Lexplore<CR>
map <leader>w :set wrap!<CR>
map <leader>d :bd<CR>
map <leader>b :bn<CR>
map <leader>s :Strikethrough<CR>
nmap n :m +1<CR>
nmap m :m -2<CR>

nnoremap <leader>c :execute &colorcolumn == '' ? 'set colorcolumn=80' : 'set colorcolumn='<CR>

set fillchars=eob:\
set fillchars=fold:\
set fillchars+=vert:┃
autocmd FileType netrw highlight CursorLine ctermfg=white ctermbg=238
autocmd FileType netrw setlocal laststatus=0 noruler noshowmode
hi netrwTreeBar ctermfg=black
autocmd FileType netrw setlocal statusline=[%n]\ %<%F\ %m%r%w&y %=\ (%l,%c)\ %P\ of\ %L

let g:netrw_keepdir = 0
let g:netrw_winsize = 30
let g:netrw_banner = 0
let g:netrw_liststyle = 3

autocmd BufRead,BufNewFile *.yaml,*.yml setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
set foldlevel=99
nnoremap <leader>F :exec foldclosed('.') == -1 ? 'normal! zM' : 'normal!

if has('win32') || has('win64')
    inoremap <C-v> <C-r>+
    vnoremap <C-Y> :silent! w !clip.exe<CR>
endif

command! -range -nargs=0 Strikethrough call s:CombineSelection(<line1>,<line2>,'0336')

function! s:CombineSelection(line1, line2, cp)
    execute 'let char = "\u'.a:cp.'"'
    execute a:line1.','.a.line2.'s/\%V[^[:cntrl:]]/$'.char.'/ge'
endfunction

