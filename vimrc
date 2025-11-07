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
map <leader>+ :vertical resize +5<CR>
map <leader>- :vertical resize -5<CR>
map <leader>c :set clipboard="unnamed"<CR>
map <leader>t :tabnew<CR>
map <leader>e :Lexplore<CR>
map <leader>w :set wrap!<CR>
map <leader>d :bd<CR>
map <leader>b :bn<CR>
map <leader>s :Strikethrough<CR>
xnoremap <silent> <leader>r :<C-U>call <SID>ReplaceSelection()<CR>
nmap n :m +1<CR>
nmap m :m -2<CR>

nnoremap <leader>c :execute &colorcolumn == '' ? 'set colorcolumn=80' : 'set colorcolumn='<CR>

set fillchars=eob:\ ,fold:\ ,vert:┃
set foldcolumn=0
autocmd FileType netrw highlight CursorLine ctermfg=white ctermbg=238
autocmd FileType netrw setlocal noruler noshowmode
autocmd FileType netrw let &l:statusline = '%{exists("b:netrw_curdir") ? fnamemodify(b:netrw_curdir, ":~") : ""}'
hi netrwTreeBar ctermfg=black
highlight! link Folded Normal
highlight! link FoldColumn Normal

let g:netrw_keepdir = 0
let g:netrw_winsize = 30
let g:netrw_banner = 0
let g:netrw_liststyle = 3

autocmd BufRead,BufNewFile *.yaml,*.yml setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
autocmd FileType yaml,yml call s:SetupYamlFolds()
set foldlevel=99
set foldtext=<SID>FoldText()
nnoremap <leader>F :exec foldclosed('.') == -1 ? 'normal! zM' : 'normal!

let g:is_wsl = has('unix') && (system('uname -r') =~? 'microsoft')

if g:is_wsl
    inoremap <C-v> <C-r>+
    vnoremap <C-Y> :silent w !clip.exe<CR>
endif

command! -range -nargs=0 Strikethrough call s:CombineSelection(<line1>,<line2>,'0336')

function! s:CombineSelection(line1, line2, cp) range
    let l:start = getpos("'<")
    let l:end = getpos("'>")
    if l:start[1] == 0 || l:end[1] == 0
        return
    endif

    let l:char = nr2char(str2nr(a:cp, 16))
    for lnum in range(a:line1, a:line2)
        let l:line = getline(lnum)

        let l:start_col = lnum == l:start[1] ? l:start[2] : 1
        let l:end_col = lnum == l:end[1] ? l:end[2] : strlen(l:line)
        if l:end_col < l:start_col
            continue
        endif

        let l:start_idx = l:start_col - 1
        let l:len = l:end_col - l:start_col + 1
        let l:prefix = strpart(l:line, 0, l:start_idx)
        let l:middle = strpart(l:line, l:start_idx, l:len)
        let l:suffix = strpart(l:line, l:start_idx + l:len)
        let l:middle_chars = split(l:middle, '\zs')
        let l:new_middle = join(map(l:middle_chars, 'v:val . l:char'), '')
        call setline(lnum, l:prefix . l:new_middle . l:suffix)
    endfor
endfunction

function! s:GetVisualSelection() abort
    let l:start = getpos("'<")
    let l:end = getpos("'>")
    if l:start[1] == 0 || l:end[1] == 0
        return ''
    endif
    if l:start[1] > l:end[1] || (l:start[1] == l:end[1] && l:start[2] > l:end[2])
        let l:tmp = l:start
        let l:start = l:end
        let l:end = l:tmp
    endif
    let l:lines = getline(l:start[1], l:end[1])
    if empty(l:lines)
        return ''
    endif
    let l:lines[0] = strpart(l:lines[0], max([l:start[2] - 1, 0]))
    let l:last = len(l:lines) - 1
    let l:end_col = l:end[2]
    if l:end_col <= 0 || l:end_col > strlen(l:lines[l:last])
        let l:end_col = strlen(l:lines[l:last])
    endif
    let l:lines[l:last] = strpart(l:lines[l:last], 0, l:end_col)
    return join(l:lines, "\n")
endfunction

function! s:ReplaceSelection() abort
    let l:selection = s:GetVisualSelection()
    if empty(l:selection)
        echo 'Nothing selected to replace'
        return
    endif

    let l:prompt = 'Replace selection with: '
    let l:replacement = ''
    let l:cancelled = 0
    call inputsave()
    try
        let l:replacement = input(l:prompt, l:selection)
    catch /^Vim:Interrupt$/
        let l:cancelled = 1
    finally
        call inputrestore()
    endtry
    if l:cancelled
        echo 'Replace cancelled'
        return
    endif

    let l:search = s:EscapeLiteralSearch(l:selection)
    let l:replace = s:EscapeLiteralReplacement(l:replacement)
    execute '%s/\V' . l:search . '/' . l:replace . '/g'
endfunction

function! s:EscapeLiteralSearch(text) abort
    let l:text = escape(a:text, '\/')
    return substitute(l:text, "\n", '\\n', 'g')
endfunction

function! s:EscapeLiteralReplacement(text) abort
    let l:text = escape(a:text, '/\&')
    return substitute(l:text, "\n", '\\r', 'g')
endfunction

function! s:FoldText() abort
    let l:line = getline(v:foldstart)
    let l:indent = matchstr(l:line, '^\s*')
    let l:text = substitute(l:line, '^\s*', '', '')
    if empty(l:text)
        let l:next = nextnonblank(v:foldstart + 1)
        if l:next > 0
            let l:text = substitute(getline(l:next), '^\s*', '', '')
        endif
    endif
    return l:indent . '▸ ' . l:text
endfunction

function! s:SetupYamlFolds() abort
    setlocal foldmethod=expr
    setlocal foldexpr=s:YamlFoldExpr(v:lnum)
    setlocal foldenable
    setlocal foldlevel=99
endfunction

function! s:YamlFoldExpr(lnum) abort
    let l:line = getline(a:lnum)
    if l:line =~# '^\s*$' || l:line =~# '^\s*#'
        return -1
    endif

    let l:curr = s:YamlIndentLevel(a:lnum)
    let l:next = s:YamlNextIndentLevel(a:lnum)

    if l:next > l:curr
        return 'a' . (l:next - l:curr)
    elseif l:next < l:curr
        return 's' . (l:curr - l:next)
    elseif l:curr == 0
        return 0
    else
        return '='
    endif
endfunction

function! s:YamlIndentWidth() abort
    return &shiftwidth > 0 ? &shiftwidth : (&tabstop > 0 ? &tabstop : 2)
endfunction

function! s:YamlIndentLevel(lnum) abort
    return indent(a:lnum) / s:YamlIndentWidth()
endfunction

function! s:YamlNextIndentLevel(lnum) abort
    let l:line_count = line('$')
    let l:idx = a:lnum + 1
    while l:idx <= l:line_count
        let l:text = getline(l:idx)
        if l:text =~# '^\s*$' || l:text =~# '^\s*#'
            let l:idx += 1
            continue
        endif
        return s:YamlIndentLevel(l:idx)
    endwhile
    return 0
endfunction
