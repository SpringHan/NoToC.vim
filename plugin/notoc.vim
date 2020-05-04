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
let g:NoToCLoaded = 1
" }}}

" FUNCTION: s:LoadSyntax() {{{
function! NtcLoadSyntax() abort
	execute &filetype != 'ntc' ? "return" : ""
	syntax match NoToCTodosLeader /^-\*/
	syntax match NoToCTodoContent /\(^-\*\s\)\@<=\(.*\)/
	syntax match NoToCTitleOneLeader /\(^-\)\s/
	syntax match NoToCTitleOneContent /\(^-\s\)\@<=\(.*\)/
	highlight link NoToCTodosLeader SpecialKey
	highlight link NoToCTodoContent Title
	highlight link NoToCTitleOneLeader WarningMsg
	highlight link NoToCTitleOneContent MoreMsg
endfunction " }}}
