call plug#begin('~/.local/share/nvim/plugged')
  Plug 'scrooloose/nerdtree'
  Plug 'tpope/vim-commentary'
  Plug 'janko-m/vim-test'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'drewtempelmeyer/palenight.vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'elixir-editors/vim-elixir'
  Plug 'mhinz/vim-mix-format'

  Plug 'elixir-lsp/elixir-ls', { 'do': { -> g:ElixirLS.compile() } }
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " Plug 'thoughtbot/vim-rspec'
  " Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  " Plug 'junegunn/fzf.vim'
call plug#end()

filetype plugin indent on
syntax on
colorscheme palenight
" highlight Normal ctermbg=NONE
" highlight nonText ctermbg=NONE
if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

let g:mix_format_on_save = 1
let g:coc_global_extensions = ['coc-elixir', 'coc-diagnostic']

let g:ElixirLS = {}
let ElixirLS.path = stdpath('config').'/plugged/elixir-ls'
let ElixirLS.lsp = ElixirLS.path.'/rel/language_server.sh'
let ElixirLS.cmd = join([
        \ 'cp .release-tool-versions .tool-versions &&',
        \ 'asdf install &&',
        \ 'mix do',
        \ 'local.hex --force --if-missing,',
        \ 'local.rebar --force,',
        \ 'deps.get,',
        \ 'compile,',
        \ 'elixir_ls.release &&',
        \ 'rm .tool-versions'
        \ ], ' ')

function ElixirLS.on_stdout(_job_id, data, _event)
  let self.output[-1] .= a:data[0]
  call extend(self.output, a:data[1:])
endfunction

let ElixirLS.on_stderr = function(ElixirLS.on_stdout)

function ElixirLS.on_exit(_job_id, exitcode, _event)
  if a:exitcode[0] == 0
    echom '>>> ElixirLS compiled'
  else
    echoerr join(self.output, ' ')
    echoerr '>>> ElixirLS compilation failed'
  endif
endfunction

function ElixirLS.compile()
  let me = copy(g:ElixirLS)
  let me.output = ['']
  echom '>>> compiling ElixirLS'
  let me.id = jobstart('cd ' . me.path . ' && git pull && ' . me.cmd, me)
endfunction

" If you want to wait on the compilation only when running :PlugUpdate
" then have the post-update hook use this function instead:

" function ElixirLS.compile_sync()
"   echom '>>> compiling ElixirLS'
"   silent call system(g:ElixirLS.cmd)
"   echom '>>> ElixirLS compiled'
" endfunction


" Then, update the Elixir language server
call coc#config('elixir', {
  \ 'command': g:ElixirLS.lsp,
  \ 'filetypes': ['elixir', 'eelixir']
  \})
call coc#config('elixir.pathToElixirLS', g:ElixirLS.lsp)

"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
  set termguicolors
endif
set background=dark
" set mouse=a
set clipboard=unnamedplus
set laststatus=2
set tabstop=2 shiftwidth=2 expandtab softtabstop=2
set colorcolumn=80
set number
set autoindent
set nowrap
set incsearch   " find the next match as we type the search
set hlsearch    " highlight search by default
" set cursorcolumn
" set textwidth=80
"
" open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
" open a NERDTree automatically when vim starts up
" autocmd vimenter * NERDTree
" map a specific key or shortcut to open NERDTree
map <C-n> :NERDTreeToggle<CR>
" close vim if the only window left open is a NERDTree
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Delete trailing white space on save
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite * :call DeleteTrailingWS()

" vim-test mappings
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>a :TestSuite<CR>
nmap <silent> <leader>l :TestLast<CR>
nmap <silent> <leader>g :TestVisit<CR>
let test#strategy = 'neovim'

let g:LanguageClient_serverCommands = {
    \ 'ruby': ['tcp://localhost:7658']
    \ }

" Configure ruby omni-completion to use the language client:
autocmd FileType ruby setlocal omnifunc=LanguageClient#complete

" " Fuzzy-find with fzf
" map <C-p> :Files<cr>
" nmap <C-p> :Files<cr>
" map <C-b> :Buffers<cr>
" nmap <C-b> :Buffers<cr>
" " View commits in fzf
" nmap <Leader>c :Commits<cr>
" " File preview in fzf
" command! -bang -nargs=? -complete=dir Files
"       \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" " Key mapping for window navigation
" nnoremap <C-J> <C-W><C-J>
" nnoremap <C-K> <C-W><C-K>
" nnoremap <C-L> <C-W><C-L>
" nnoremap <C-H> <C-W><C-H>

" " Save pressing Esc twice
" " map <Esc><Esc> :w<CR>

" " Open new split panes to right and bottom, which feels more natural than Vim‚Äôs default
" set splitbelow
" set splitright

"
nnoremap <C-c> :let @+ = expand("%")<CR>
nnoremap <C-C> :let @+ = expand("%:p")<CR>
:vnoremap <C-c> "+y

" CtrlP auto cache clearing.
" ----------------------------------------------------------------------------
function! SetupCtrlP()
  if exists("g:loaded_ctrlp") && g:loaded_ctrlp
    augroup CtrlPExtension
      autocmd!
      autocmd FocusGained  * CtrlPClearCache
      autocmd BufWritePost * CtrlPClearCache
    augroup END
  endif
endfunction
if has("autocmd")
  autocmd VimEnter * :call SetupCtrlP()
endif

" " RSpec.vim mappings
" " nnoremap <Leader>t :call RunCurrentSpecFile()<CR>
" " nnoremap <Leader>s :call RunNearestSpec()<CR>
" " nnoremap <Leader>l :call RunLastSpec()<CR>
" " nnoremap <Leader>a :call RunAllSpecs()<CR>
" " let g:rspec_command = '!rspec --drb {spec}'
" " let g:rspec_runner = 'os_x_iterm2'
