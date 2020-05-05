" A plugin can control the notes and todos in (Neo)Vim.
" Author: SpringHan <springchohaku@qq.com>
" Last Change: <+++>
" Version: 1.0.0
" Repository: https://github.com/SpringHan/NoToC.vim.git
" Lisence: MIT

" Autoload {{{
if exists('g:NoToCLoaded')
	finish
endif
autocmd BufNewFile,BufRead *.ntc setfiletype ntc
autocmd BufNewFile,BufRead *.ntc call NtcLoadSyntax()
autocmd BufEnter *.ntc setlocal foldmethod=expr
autocmd BufNewFile,BufRead,BufWrite,BufWritePost *.ntc
			\ setlocal foldexpr=NtcFoldRule(v:lnum)
autocmd BufEnter *.ntc nnoremap <silent><buffer> <Tab> :silent! normal za<CR>
let g:NoToCLoaded = 1
" }}}

" Commands {{{
" }}}

" FUNCTION: NtcFoldRule() {{{
function! NtcFoldRule(lnum)
	if getline(a:lnum) =~ '\(^-\)\s'
		return 1
	elseif getline(a:lnum) =~ '\(^+-\)\s'
		return 2
	elseif getline(a:lnum) =~ '\(^++-\)\s'
		return 3
	elseif getline(a:lnum) =~ '\(^+++-\)\s'
		return 4
	elseif getline(a:lnum) =~ '\(^-\*\)\s'
		return 1
	elseif getline(a:lnum) =~ '\(^--\*\)\s'
		return 2
	else
		return 0
	endif
endfunction " }}}

" FUNCTION: s:LoadSyntax() {{{
function! NtcLoadSyntax() abort
	execute &filetype != 'ntc' ? "return" : ""
	execute exists('g:NtcSyntaxLoaded') ?
				\ "autocmd! BufNewFile,BufRead *.ntc call NtcLoadSyntax() | return" :
				\ "let g:NtcSyntaxLoaded = 1"
	syntax clear
	syntax match NoToCTodoLeader /\(^-\*\)\s/
	syntax match NoToCTodoContent /\(^-\*\s\[.\]\)\@<=\(.*\)/
	syntax match NoToCTodoTwoLeader /\(^--\*\)\s/
	syntax match NoToCTodoTwoContent /\(^--\*\s\[.\]\)\@<=\(.*\)/
	syntax match NoToCTodoSign /\(^-*\*\s\)\@<=\(\[.\]\)/
	syntax match NoToCTitleOneLeader /\(^-\)\s/
	syntax match NoToCTitleOneContent /\(^-\s\)\@<=\(.*\)/
	syntax match NoToCTitleTwoLeader /\(^+-\)\s/
	syntax match NoToCTitleTwoContent /\(^+-\s\)\@<=\(.*\)/
	syntax match NoToCTitleThreeLeader /\(^++-\)\s/
	syntax match NoToCTitleThreeContent /\(^++-\s\)\@<=\(.*\)/
	syntax match NoToCTitleFourLeader /\(^+++-\)\s/
	syntax match NoToCTitleFourContent /\(^+++-\s\)\@<=\(.*\)/
	highlight NoToCDone cterm=bold ctermfg=223 ctermbg=235 gui=bold guifg=fg guibg=bg
	highlight link NoToCTodoSign NoToCDone
	highlight link NoToCTodoLeader SpecialKey
	highlight link NoToCTodoContent Title
	highlight link NoToCTodoTwoLeader Conceal
	highlight link NoToCTodoTwoContent Normal
	highlight link NoToCTitleOneLeader WarningMsg
	highlight link NoToCTitleOneContent MoreMsg
	highlight link NoToCTitleTwoLeader Question
	highlight link NoToCTitleTwoContent Constant
	highlight link NoToCTitleThreeLeader Question
	highlight link NoToCTitleThreeContent Conceal
	highlight link NoToCTitleFourLeader Question
	highlight link NoToCTitleFourContent Normal
endfunction " }}}

" FUNCTION: s:JumpToNext() {{{
function! s:JumpToNext() abort
endfunction " }}}

" FUNCTION: s:TodoControl() {{{
function! s:TodoControl() abort
	execute &filetype != 'ntc' ? "return" : ""
	if matchstr(getline(line('.')), '\(^-*\*\s\)\@<=\(\[.\]\)') == '[ ]'
	elseif matchstr(getline(line('.')), '\(^-*\*\s\)\@<=\(\[.\]\)') == '[x]'
	endif
endfunction " }}}
