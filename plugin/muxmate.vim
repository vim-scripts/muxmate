" ============================================================================
" File:        muxmate.vim
" Description: tmux vim plugin
" Maintainer:  William Estoque <william.estoque at gmail dot com>
" Last Change: 25 Apr, 2012
" License:     MIT
" ============================================================================

let s:Version        = "0.0.1"
let s:currentIdx = ""
let s:paneList    = []
let s:selection      = 0


function ExecuteSpecLine()
  let cmd = system("which rspec") . " " . expand("%:p") . " --line_number " . line(".")
  call SendKeys(cmd)
endfunction

function ExecuteSpecFile()
  let cmd = system("which rspec") . " " . expand("%:p")
  call SendKeys(cmd)
endfunction

function ExecuteSpecs()
  let cmd = system("which rake") . " spec"
  call SendKeys(cmd)
endfunction

function ExecuteCommand()
  call SendKeys(input("Shell command: "))
endfunction

function EscapeStr(str)
    let res = substitute(a:str, ";$", "\\\\;", "")
    return shellescape(res)
endfunction

function SendKeys(cmd)
  if ("x" . s:currentIdx) == "x"
    call ShowMenu()
  endif
  let escapedcmd = EscapeStr(a:cmd)
  call system("tmux send-keys -t " . substitute(s:paneList[s:currentIdx], ': .*$', ' ', '') . "-l " . escapedcmd)
  call system("tmux send-keys -t " . substitute(s:paneList[s:currentIdx], ': .*$', ' ', '') . "Enter")
endfunction

function GetPaneList()
  let panes = system("tmux list-panes -a")
  let s:paneList = split(panes, "\n")
  return 1
endfunction

function EchoPrompt()
  echo "Select a tmux pane"
  echo "======================="

  let num = 0
  for pane in s:paneList
    echo "(" . num . ") " . s:paneList[num]
    let num = num + 1
  endfor
endfunction

" Stolen from NERDTree
function ShowMenu()
  call GetPaneList()

  let done = 0
  while !done
    redraw!
    call EchoPrompt()
    let key  = getchar()
    let done = HandleKeypress(key)
  endwhile
endfunction

function HandleKeypress(key)
  echo "HandleKeyPress(" . nr2char(a:key) . ") called"
  if a:key == 27 "escape
    return 1
  endif

  if a:key == "\r" || a:key == "\n" "enter and ctrl-j
    return 1
  endif

  let s:currentIdx = (a:key - char2nr('0'))
  redraw!
  echo "Selected tmux pane: " . s:paneList[s:currentIdx]
  return 1
endfunction

" Map for outside use
nmap <Leader>s :call ShowMenu()<CR>
nmap <Leader>sx :call ExecuteCommand()<CR>
nmap <Leader>sl :call ExecuteSpecLine()<CR>
nmap <Leader>sf :call ExecuteSpecFile()<CR>
nmap <Leader>sS :call ExecuteSpecs()<CR>
