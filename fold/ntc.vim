" A plugin can control the notes and todos in (Neo)Vim.
" Author: SpringHan <springchohaku@qq.com>
" Last Change: <+++>
" Version: 1.0.0
" Repository: https://github.com/SpringHan/NoToC.vim.git
" Lisence: MIT

" Autostart {{{
if exists('g:NoToCFoldLoaded')
	finish
endif
let g:NoToCFoldLoaded = 1
" }}}

" FUNCTION: {{{ NtcFolds() { Folding the contents in *.ntc }
function! NtcFolds() abort
	execute !exists('g:NoToCFoldCache') ? "echohl Error | echo 'You have not set".
				\ " the g:NoToCFoldCache!' | echohl None | return" : ""
endfunction " }}}

" FUNCTION: {{{ NtcFoldAct() { Folding actions }
function! NtcFoldAct() abort
endfunction " }}}
