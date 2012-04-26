" ============================================================================
" File:        muxmate.vim
" Description: tmux vim plugin
" Maintainer:  William Estoque <william.estoque at gmail dot com>
" Last Change: 25 Apr, 2012
" License:     MIT
" ============================================================================

let s:Version        = "0.0.1"
let s:currentSession = ""
let s:sessionList    = []
let s:selection      = 0


function ExecuteSpecLine()
  let cmd = system("which rspec") . " " . expand("%:p") . " --line_number " . line(".")
  call SendKeys(shellescape(cmd))
endfunction

function ExecuteSpecFile()
  let cmd = system("which rspec") . " " . expand("%:p")
  call SendKeys(shellescape(cmd))
endfunction

function ExecuteSpecs()
  let cmd = system("which rake") . " spec"
  call SendKeys(shellescape(cmd))
endfunction

function ExecuteCommand()
  let cmd = shellescape(input("Shell command: "))
  call SendKeys(cmd)
endfunction

function SendKeys(cmd)
  if s:currentSession == ""
    call ShowMenu()
  endif

  call system("tmux send-keys -t " . s:currentSession . " " . a:cmd . " Enter")
endfunction

function SetSessionList()
  let sessions      = system("tmux ls | awk '{print $1}'")
  let s:sessionList = split(sessions, "\n") 
  return 1
endfunction

function EchoPrompt()
  echo "Select a tmux session"
  echo "======================="

  let num = 0
  for session in s:sessionList
    let s:sessionList[num] = substitute(session, ":", "", "g")
    echo "(" . num . ") " . s:sessionList[num]
    let num = num + 1
  endfor
endfunction

" Stolen from NERDTree
function ShowMenu()
  call SetSessionList()

  let done = 0
  while !done
    redraw!
    call EchoPrompt()
    let key  = nr2char(getchar())
    let done = HandleKeypress(key)
  endwhile

  redraw!
  echo "Selected tmux session: " . s:currentSession
endfunction

function HandleKeypress(key)
  let value = get(s:sessionList, a:key)
  if a:key == nr2char(27) "escape
    return 1
  endif

  if a:key == "\r" || a:key == "\n" "enter and ctrl-j
    return 1
  endif

  if value == "0"
    return 0
  else
    let s:currentSession = value
    return 1
  endif
endfunction

" Map for outside use
nmap <Leader>s :call ShowMenu()<CR>
nmap <Leader>sx :call ExecuteCommand()<CR>
nmap <Leader>sl :call ExecuteSpecLine()<CR>
nmap <Leader>sf :call ExecuteSpecFile()<CR>
nmap <Leader>sS :call ExecuteSpecs()<CR>
