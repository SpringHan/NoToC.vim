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
let g:NoToCLoaded = 1
" runtime fold/ntc.vim " Load the fold script file
autocmd BufNewFile,BufRead *.ntc setfiletype ntc
autocmd BufNewFile,BufRead *.ntc call NtcLoadSyntax()
autocmd BufEnter *.ntc setlocal foldmethod=expr
autocmd BufNewFile,BufRead,BufWrite,TextChanged *.ntc
			\ setlocal foldexpr=NtcFoldRule(v:lnum)
autocmd BufEnter *.ntc nnoremap <silent><buffer> <Tab> :silent! normal za<CR>
autocmd BufEnter *.ntc nnoremap <silent><buffer> <CR> :NtcTodoControl<CR>
autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-o> :NtcNewItem<CR>
autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-y> :NtcYankItem<CR>
" }}}

" Commands {{{
command! -nargs=0 NtcTodoControl call s:TodoControl()
command! -nargs=0 NtcNewItem call s:NewItem()
command! -nargs=0 NtcYankItem call s:YankItem()
" }}}

" FUNCTION: {{{ NtcFoldRule()
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
		if getline(a:lnum - 1) =~ '^\n'
			return 1
		endif
		return 'a1'
	elseif getline(a:lnum) =~ '\(^--\*\)\s'
		if getline(a:lnum - 1) =~ '\(^-\*\)\s'
			return 'a1'
		elseif getline(a:lnum - 1) =~ '\(^--\*\)\s'
			return '='
		endif
		return 2
	elseif getline(a:lnum) =~ '^\t\(.*\)'
		return 'a1'
	else
		return 0
	endif
endfunction " }}}

" FUNCTION: {{{ s:LoadSyntax()
function! NtcLoadSyntax() abort
	execute &filetype != 'ntc' ? "return" : ""
	execute exists('g:NtcSyntaxLoaded') ?
				\ "autocmd! BufNewFile,BufRead *.ntc call NtcLoadSyntax() | return" :
				\ "let g:NtcSyntaxLoaded = 1"
	syntax clear
	syntax match NoToCTodoLeader /\(^-\*\)\s/
	syntax match NoToCTodoContent /\(^-\*\s\[.\]\s\)\@<=\(.*\)/
	syntax match NoToCTodoTwoLeader /\(^--\*\)\s/
	syntax match NoToCTodoTwoContent /\(^--\*\s\[.\]\s\)\@<=\(.*\)/
	syntax match NoToCTodoSign /\(^-\{1,2\}\*\s\)\@<=\(\[.\]\)/
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

" FUNCTION: {{{ s:TodoNodes(lastNodeLine, foldType)
function! s:TodoNodes(lastNodeLine, foldType) abort
	let l:lastNode = a:lastNodeLine
	let l:i = 1
	while l:i == 1
		if getline(l:lastNode + 1) =~ '\(^--\*\)\s'
			let l:todoContent = matchstr(getline(l:lastNode + 1),
						\ '\(^--\*\s\[.\]\s\)\@<=\(.*\)')
			execute a:foldType == 0 ?
						\ "call setline(l:lastNode + 1, '--* [x] '.l:todoContent)" :
						\ "call setline(l:lastNode + 1, '--* [ ] '.l:todoContent)"
		else
			let l:i = 0
		endif
		let l:lastNode += 1
	endwhile
	unlet l:lastNode l:i l:todoContent
endfunction " }}}

" FUNCTION: {{{ s:TodoControl()
function! s:TodoControl() abort
	execute &filetype != 'ntc' ? "return" : ""
	let l:todoType = matchstr(getline(line('.')), '\(^-\{1,2\}\*\)') == '-*' ? 1 :
				\ 2
	let l:todoContent = matchstr(getline(line('.')), '\(^-\{1,2\}\*\s\[.\]\s\)\@<=\(.*\)')
	let l:matchResult = matchstr(getline(line('.')), '\(^-\{1,2\}\*\s\)\@<=\(\[.\]\)')
	if l:matchResult == '[ ]'
		if l:todoType == 1
			call setline(line('.'), '-* [x] '.l:todoContent)
			call s:TodoNodes(line('.'), 0)
		else
			call setline(line('.'), '--* [x] '.l:todoContent)
		endif
	elseif l:matchResult == '[x]'
		if l:todoType == 1
			call setline(line('.'), '-* [ ] '.l:todoContent)
			call s:TodoNodes(line('.'), 1)
		else
			call setline(line('.'), '--* [ ] '.l:todoContent)
		endif
	endif
	execute "write"
	unlet l:todoType l:todoContent l:matchResult
endfunction " }}}

" FUNCTION: {{{ s:JudgeCont(type, lineCont)[ `type` is the new item's type,
" `line` is the current line number, `lineCont` is the current line's
" content. ] { Judgment method to create a new item. }
function! s:JudgeCont(type, line, lineCont) abort
	if getline(a:line + 1) != ''
		call append(a:line, '')
	endif
	if a:type == 2
		call setline(a:line + 1, a:lineCont =~ '^\s*$' ? '- ' : a:lineCont =~
					\ '\(^-\)\s' ? '+- ' : a:lineCont =~ '\(^+-\)\s' ? '++- ' :
					\ a:lineCont =~ '\(^++-\)\s' ? '+++- ' : '')
		call cursor(a:line + 1, 0)
		startinsert!
	elseif a:type == 3
		call setline(a:line + 1, '')
		call cursor(a:line + 1, 0)
	elseif a:type == 4
		call setline(a:line + 1, '	')
		call cursor(a:line + 1, 0)
		startinsert!
	elseif a:type == -1
		return
	else
		call setline(a:line + 1, a:type == 0 ? '-* [ ] ' : '--* [ ] ')
		call cursor(a:line + 1, 0)
		startinsert!
	endif
endfunction " }}}

" FUNCTION: {{{ s:YankItem() { Create a new item as same as the previous }
function! s:YankItem() abort
	let l:currentLine = line('.')
	let l:currentLineContent = getline(l:currentLine)
	if getline(l:currentLine + 1) != ''
		call append(l:currentLine, '')
	endif
	if l:currentLineContent =~ '\(^-*\*\s\[.\]\s\)'
		call setline(l:currentLine + 1, matchstr(l:currentLineContent,
					\ '\(^-*\*\)\(\s\[.\]\s.*\)\@=').' [ ] ')
		call cursor(l:currentLine + 1, 0)
		startinsert!
	elseif l:currentLineContent =~ '\(^.*-\s\)'
		call setline(l:currentLine + 1, matchstr(l:currentLineContent,
					\ '\(^.*-\)\(\s.*\)\@=').' ')
		call cursor(l:currentLine + 1, 0)
		startinsert!
	elseif l:currentLineContent =~ '\t\(.*\)'
		call setline(l:currentLine + 1, '	')
		call cursor(l:currentLine + 1, 0)
		startinsert!
	endif
	unlet l:currentLine l:currentLineContent
endfunction " }}}

" FUNCTION: {{{ s:NewItem() { Create a new item. }
function! s:NewItem() abort
	let l:currentLine = line('.')
	let l:currentLineContent = getline(l:currentLine)
	let l:newItem = input('Input the new item type:')
	execute l:newItem == 'x' ? "return" : ""
	call s:JudgeCont(l:newItem == 't1' ? 0 : l:newItem == 't2' ? 1 :
				\ l:newItem == 'n' ? 2 : l:newItem == 'o' ? 3 :
				\ l:newItem == 'c' ? 4 : -1,
				\ l:currentLine, l:currentLineContent)
	unlet l:currentLine l:currentLineContent l:newItem
endfunction " }}}
