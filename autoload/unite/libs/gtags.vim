
" global cmd result option formats {{{
let s:format = {
      \ "ctags-mod" : {},
      \ "ctags-x" : {},
      \ }

function! s:format["ctags-x"].func(line)
  let l:items = matchlist(a:line, '\(\d\+\)\s\+\(.*\.\S\+\)\s\(.*\)$')
  if len(l:items) != 4
    throw "internal error, result of ctags-x is broken"
  endif
  return {
        \  "kind": "jump_list",
        \  "word" : l:items[0],
        \  "action__path" : l:items[2],
        \  "action__line" : l:items[1],
        \  "action__text" : l:items[3],
        \}
endfunction

function! s:format["ctags-mod"].func(line)
  let l:items = matchlist(a:line, '^\([^\t]\+\)\t\+\(\d\+\)\t\+\(.\+\)$')
  return {
        \  "kind": "jump_list",
        \  "word" : l:items[0],
        \  "action__path" : l:items[1],
        \  "action__line" : l:items[2],
        \  "action__text" : l:items[3],
        \}
endfunction
" }}}

" execute global command and return result
function! unite#libs#gtags#exec_global(option, long_option, pattern)
  " build command
  let l:option = a:long_option . ' -q'. a:option
  let l:cmd = g:unite_source_gtags_global_cmd . ' ' . l:option . 'e ' . g:unite_source_gtags_shell_quote . a:pattern . g:unite_source_gtags_shell_quote

  " --result option
  let l:result_options = exists("g:unite_source_gtags_result_option") ? [g:unite_source_gtags_result_option] : keys(s:format)
  for result_option in l:result_options
    let l:exe_cmd = l:cmd . " --result=" . result_option
    let l:result = system(l:exe_cmd)

    if v:shell_error != 0
      " exit global command with error
      if v:shell_error == 2
        " not supported result option try next option
        continue
      elseif v:shell_error == 3
        call unite#util#print_error('GTAGS not found.')
      else
        " unknown error
        call unite#util#print_error('global command failed. command line: ' . l:cmd. '. exit with '. string(v:shell_error))
      endif
      " interruppt execution
      return ''
    else
      if !exists("g:unite_source_gtags_result_option")
        let g:unite_source_gtags_result_option = result_option
      endif
      return l:result
    endif
  endfor
  " all result options are invalid
  return ''
endfunction

" build unite items from global command result
function! unite#libs#gtags#result2unite(source, result)
  if empty(a:result)
    return []
  endif
  return map(split(a:result, '\r\n\|\r\|\n'),
        \ 'extend(s:format[g:unite_source_gtags_result_option].func(v:val), {"source" : a:source})')
endfunction
