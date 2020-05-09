" A plugin can control the notes and todos in (Neo)Vim.
" Author: SpringHan <springchohaku@qq.com>
" Last Change: <+++>
" Version: 1.0.0
" Repository: https://github.com/SpringHan/NoToC.vim.git &&
" https://gitee.com/springhan/NoToC.vim.git
" Lisence: MIT

" Autoload {{{
if exists('g:NoToCLoaded')
	finish
endif
let g:NoToCLoaded = 1
" runtime fold/ntc.vim " Load the fold script file
autocmd BufNewFile,BufRead *.ntc setfiletype ntc
autocmd BufNewFile,BufRead *.ntc NtcSyntaxReload
if !exists('g:NoToCDefaultKeys') || g:NoToCDefaultKeys == 1
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <CR>     :NtcTodoControl<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-o>    :NtcNewItem<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-y>    :NtcYankItem<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-c>    :NtcTypeChange<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-k>    :NtcItemPrev<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-j>    :NtcItemNext<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <M-k>    :NtcLevelItemPrev<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <M-j>    :NtcLevelItemNext<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-UP>   :NtcItemMoveUp<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-DOWN> :NtcItemMoveDown<CR>
	autocmd BufEnter *.ntc nnoremap <silent><buffer> <C-r>    :NtcResetCont<CR>
endif
" }}}

" Commands {{{
command! -nargs=0 NtcTodoControl call s:TodoControl()
command! -nargs=0 NtcNewItem call s:ItemAct(0)
command! -nargs=0 NtcTypeChange call s:ItemAct(1)
command! -nargs=0 NtcYankItem call s:YankItem()
command! -nargs=0 NtcSyntaxReload call s:LoadSyntax()
command! -nargs=0 NtcItemPrev call s:JumpNode(0, 'up')
command! -nargs=0 NtcItemNext call s:JumpNode(0, 'down')
command! -nargs=0 NtcLevelItemPrev call s:JumpNode(1, 'up')
command! -nargs=0 NtcLevelItemNext call s:JumpNode(1, 'down')
command! -nargs=0 NtcItemMoveUp call s:ItemMove(0)
command! -nargs=0 NtcItemMoveDown call s:ItemMove(1)
command! -nargs=0 NtcResetCont call s:ResetCont()
" }}}

" FUNCTION: {{{ s:NodeType(cont)[ `cont` is the content that needs to check ]
" { Return the content's type }
function! s:NodeType(cont) abort
	if a:cont =~ '\(^+*-\)\(\s.*\)' " Title
		let l:type = 0
	elseif a:cont =~ '\(^-*\*\)\(\s\[.\]\s.*\)' " Todo
		let l:type = 1
	elseif a:cont =~ '^\t.*' " Notes
		let l:type = 2
	else
		let l:type = -1
	endif
	return l:type
endfunction " }}}

" FUNCTION: {{{ s:NodeLevel(cont, type)[ `cont` is the content that needs to
" judge, `type` is the item's type ] { Return the item's level }
function! s:NodeLevel(cont, type) abort
	if a:type == 0 " Title
		let l:match = matchstr(a:cont, '\(^+*-\)\(\s.*\)\@=')
		let l:level = l:match == '-' ? 1 : l:match == '+-' ? 2 : l:match == '++-'
					\ ? 3 : l:match == '+++-' ? 4 : 4
	elseif a:type == 1 " Todo
		let l:match = matchstr(a:cont, '\(^-*\*\)\(\s\[.\].*\)\@=')
		let l:level = l:match == '-*' ? 1 : l:match == '--*' ? 2 : 2
	elseif a:type == 2 " Notes
		let l:match = 'none'
		let l:level = 1
	endif
	unlet l:match
	return l:level
endfunction " }}}

" FUNCTION: {{{ s:LevelCont(level, type, cont)[ `level` is the item's level,
" `type` is the item's type, `cont` is the content type ] { Return the Content
" of item's level }
function! s:LevelCont(level, type, cont) abort
	if a:type == 0 " Title
		if a:cont == 0 " Normal
			let l:content = a:level == 1 ? '-' : a:level == 2 ? '+-' : a:level == 3 ?
						\ '++-' : a:level == 4 ? '+++-' : ''
		elseif a:cont == 1 " Pattern
			let l:content = a:level == 1 ? '\(^-\)\(\s.*\)\@=' : a:level == 2 ?
						\ '\(^+-\)\(\s.*\)\@=' : a:level == 3 ? '\(^++-\)\(\s.*\)\@=' :
						\ a:level == 4 ? '\(^+++-\)\(\s.*\)\@=' : ''
		endif
	elseif a:type == 1 " Todo
		if a:cont == 0 " Normal
			let l:content = a:level == 1 ? '-*' : a:level == 2 ? '--*' : ''
		elseif a:cont == 1 " Pattern
			let l:content = a:level == 1 ? '\(^-\*\)\(\s\[.\]\s.*\)\@=' : a:level == 2 ?
						\ '\(^--\*\)\(\s\[.\]\s.*\)\@=' : ''
		endif
	elseif a:type == 2 " Notes
		if a:cont == 0 " Normal
			let l:content = '	'
		elseif a:cont == 1 " Pattern
			let l:content = '\(^\t.*\)'
		endif
	endif
	return l:content
endfunction " }}}

" FUNCTION: {{{ s:LoadSyntax() { Load the syntax }
function! s:LoadSyntax() abort
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

" FUNCTION: {{{ s:TodoControl() { Done or undone the todo }
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

" FUNCTION: {{{ s:SearchItem(type, lineNum)[ `type` is the item's type,
" `lineNum` is the number of the current line ] { Search the parent item and
" return the node item level }
function! s:SearchItem(type, lineNum) abort
	if a:type == 0 " Title
		for l:line in reverse(range(1, a:lineNum))
			let l:lineCont = getline(l:line)
			if l:lineCont =~ '\(^+*-\)\s\(.*\)'
				let l:prevLevel = l:lineCont
				break
			elseif l:lineCont == ''
				let l:prevLevel = 'none'
				break
			endif
		endfor
		echom l:prevLevel
		unlet l:line l:lineCont
		return l:prevLevel == 'none' ? 1 : s:NodeLevel(l:prevLevel, 0) + 1
	elseif a:type == 1 " Todo
		for l:line in reverse(range(1, a:lineNum))
			let l:lineCont = getline(l:line)
			if l:lineCont =~ '^-*\*\s\[.\]\s.*'
				let l:prevLevel = l:lineCont
				break
			elseif l:lineCont == ''
				let l:prevLevel = 'none'
				break
			endif
		endfor
		unlet l:line l:lineCont
		return l:prevLevel == 'none' ? 1 : s:NodeLevel(l:prevLevel, 1) + 1
	endif
endfunction " }}}

" FUNCTION: {{{ s:JudgeCont(type, lineCont)[ `type` is the new item's type,
" `line` is the current line number, `lineCont` is the current line's
" content. ] { Judgment method to create a new item. }
function! s:JudgeCont(type, line, lineCont) abort
	if getline(a:line + 2) != ''
		if getline(a:line + 1) == ''
			execute a:line != 1 ? "call append(a:line + 1, '')" :
						\ a:lineCont != '' ? "call append(a:line + 1, '')" : ""
		endif
	endif
	execute getline(a:line + 1) != '' ? "call append(a:line, '')" : ""
	if a:type == 1 || a:type == 0
		call setline(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1,
					\ a:type == 0 ? '-* [ ] ' : '--* [ ] ')
		call cursor(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, 0)
		startinsert!
	elseif a:type == 2
		let l:titleLevel = s:SearchItem(0, a:line)
		call setline(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1,
					\ l:titleLevel == 1 ? '- ' : l:titleLevel == 2 ? '+- ' :
					\ l:titleLevel == 3 ? '++- ' : l:titleLevel == 4 ? '+++- ' :
					\ l:titleLevel == 5 ? '+++- ' : '')
		call cursor(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, 0)
		startinsert!
		unlet l:titleLevel
	elseif a:type == 3
		call setline(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, '')
		call cursor(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, 0)
	elseif a:type == 4
		call setline(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, '	')
		call cursor(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, 0)
		startinsert!
	elseif a:type == 9
		let l:todolevel = s:SearchItem(1, a:line)
		call setline(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1,
					\ l:todolevel == 1 ? '-* [ ] ' : l:todolevel == 2 ? '--* [ ] ' :
					\ l:todolevel == 3 ? '--* [ ] ' : '')
		call cursor(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, 0)
		startinsert!
		unlet l:todolevel
	elseif a:type == -1
		echohl Error | echom "[NoToC.vim]: The type of item is error!" | echohl None
		return
	else
		call setline(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1,
					\ a:type == 5 ? '- ' : a:type == 6 ? '+- ' : a:type == 7 ?
					\ '++- ' : '+++- ')
		call cursor(a:line == 1 && a:lineCont == '' ? a:line : a:line + 1, 0)
		startinsert!
	endif
endfunction " }}}

" FUNCTION: {{{ s:YankItem() { Create a new item as same as the previous }
function! s:YankItem() abort
	let l:currentLine = line('.')
	let l:currentLineContent = getline(l:currentLine)
	if getline(l:currentLine + 2) != '' && getline(l:currentLine + 1) == ''
		call append(l:currentLine + 1, '')
	endif
	execute getline(l:currentLine + 1) != '' ? "call append(l:currentLine, '')" :
				\ ""
	if getline(l:currentLine + 1) != ''
		call append(l:currentLine, '')
	endif
	if l:currentLineContent =~ '\(^-*\*\s\[.\]\s\)'
		call setline(l:currentLine + 1, matchstr(l:currentLineContent,
					\ '\(^-*\*\)\(\s\[.\]\s.*\)\@=').' [ ] ')
		call cursor(l:currentLine + 1, 0)
		startinsert!
	elseif l:currentLineContent =~ '\(^+*-\s\)'
		call setline(l:currentLine + 1, matchstr(l:currentLineContent,
					\ '\(^+*-\)\(\s.*\)\@=').' ')
		call cursor(l:currentLine + 1, 0)
		startinsert!
	elseif l:currentLineContent =~ '\t\(.*\)'
		call setline(l:currentLine + 1, '	')
		call cursor(l:currentLine + 1, 0)
		startinsert!
	endif
	unlet l:currentLine l:currentLineContent
endfunction " }}}

" FUNCTION: {{{ s:ItemAct(type)[ `type` is the action type for items ] {
" Create a new item or change a item's type }
function! s:ItemAct(type) abort
	let l:currentLine = line('.')
	let l:currentLineContent = getline(l:currentLine)
	if a:type == 0
		let l:newItem = input('Input the new item type:')
		execute l:newItem == 'x' || l:newItem == '' ? "return" : ""
		call s:JudgeCont(l:newItem == 't1' ? 0 : l:newItem == 't2' ? 1 :
					\ l:newItem == 'n' ? 2 : l:newItem == 'o' ? 3 :
					\ l:newItem == 'c' ? 4 : l:newItem == 'n1' ? 5 : l:newItem == 'n2'
					\ ? 6 : l:newItem == 'n3' ? 7 : l:newItem == 'n4' ? 8 :
					\ l:newItem == 't' ? 9 : -1,
					\ l:currentLine, l:currentLineContent)
		unlet l:currentLine l:currentLineContent l:newItem
	elseif a:type == 1
		let l:itemNewType = input('Input the item new type:')
		execute l:itemNewType == 'x' || l:itemNewType == '' ? "return" : ""
		let l:content = matchstr(l:currentLineContent, l:currentLineContent =~
					\ '\(^+*-\)\s\(.*\)' ? '\(^+*-\s\)\@<=\(.*\)' :
					\ l:currentLineContent =~ '^-*\*\s\[.\]\s.*' ?
					\ '\(^-*\*\s\[.\]\s\)\@<=\(.*\)' : l:currentLineContent =~ '^\t.*' ?
					\ '\(^\t\)\@<=\(.*\)' : '\(.*\)')
		let l:newType = l:itemNewType == 't1' ? '-* [ ] ' :
					\ l:itemNewType == 't2' ? '--* [ ] ' : l:itemNewType == 'n1' ?
					\ '- ' : l:itemNewType == 'n2' ? '+- ' : l:itemNewType == 'n3' ?
					\ '++- ' : l:itemNewType == 'n4' ? '+++- ' : l:itemNewType == 'c' ?
					\ '	' : ''
		call setline(l:currentLine, l:newType.l:content)
		unlet l:currentLine l:currentLineContent l:itemNewType l:content l:newType
	endif
endfunction " }}}

" FUNCTION: {{{ s:JumpNode(type)[ `type` is the jump type, `direct` is the
" jump direction ] { Jump to the item nodes }
function! s:JumpNode(type, direct) abort
	let l:lines = line('.')
	let l:linesCont = getline(l:lines)
	let l:linesType = s:NodeType(l:linesCont)
	let l:currentLevel = s:NodeLevel(getline(l:lines), l:linesType)
	if a:type == 0 " Jump to the item that has the same level
		for l:line in a:direct == 'up' ? reverse(range(1, l:lines - 1)) :
					\ range(l:lines + 1, line('$')) " previous & next
			let l:lineCont = getline(l:line)
			if l:lineCont =~ s:LevelCont(l:currentLevel, l:linesType, 1)
				let l:gotoLine = l:line | break
			endif
		endfor
	elseif a:type == 1 " Jump to the level of title
		for l:line in a:direct == 'up' ? reverse(range(1, l:lines - 1)) :
					\ range(l:lines + 1, line('$')) " previous & next
			let l:lineCont = getline(l:line)
			if l:lineCont =~ s:LevelCont(1, l:linesType, 1)
				let l:gotoLine = l:line | break
			endif
		endfor
	endif
	unlet l:lines l:linesType l:linesCont
	execute exists('l:gotoLine') ? "call cursor(l:gotoLine, 0)" : ""
endfunction " }}}

" FUNCTION: {{{ s:ItemMove(direct)[ `direct` is the move direction ] { move
" the item by the direction }
function! s:ItemMove(direct) abort
	let l:currentLine = line('.')
	let l:currentCont = getline(l:currentLine)
	if a:direct == 0 " Up
		let l:prevCont = getline(l:currentLine - 1)
		call setline(l:currentLine, l:prevCont)
		call setline(l:currentLine - 1, l:currentCont)
		call cursor(l:currentLine - 1, 0)
		unlet l:prevCont
	elseif a:direct == 1 " Down
		let l:nextCont = getline(l:currentLine + 1)
		call setline(l:currentLine, l:nextCont)
		call setline(l:currentLine + 1, l:currentCont)
		call cursor(l:currentLine + 1, 0)
		unlet l:nextCont
	endif
	execute "write"
	unlet l:currentLine l:currentCont
endfunction " }}}

" FUNCTION: {{{ s:ResetCont() { Reset the item's content }
function! s:ResetCont() abort
	let l:line = line('.')
	let l:cont = getline(l:line)
	let l:itemType = s:NodeType(l:cont)
	let l:itemLevel = s:NodeLevel(l:cont, l:itemType)
	let l:itemLeader = s:LevelCont(l:itemLevel, l:itemType, 0)
	call setline(l:line, l:itemType == 0 ? l:itemLeader.' ' : l:itemType == 1 ?
				\ l:itemLeader.' [ ] ' : l:itemType == 2 ? l:itemLeader : '')
	call cursor(l:line, 0)
	startinsert!
	unlet l:line l:cont l:itemType l:itemLevel l:itemLeader
endfunction " }}}
