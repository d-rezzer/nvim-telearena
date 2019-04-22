
if !exists('s:jobid')
    let s:jobid = 0
endif

let s:scriptdir = resolve(expand('<sfile>:p:h') . '/..')
let s:bin = s:scriptdir . '/target/debug/nvim-telearena'

function! telearena#init()
    call telearena#connect()
endfunction

function! telearena#connect()
    let result = s:StartJob()

    if 0 == result
        echoerr "teleareana: cannot start rpc process."
    elseif -1 == result
        echoerr "tele-arena: rpc process is not executable. "
    else
        let s:jobid = result
        call s:configureJob(result)
    endif
endfunction

function! telearena#reset()
  let s:jobid = 0
endfunction 

function! s:ConfigureJob(jobid)
    augroup telearena
        autocmd!

        autocmd VimLeavePre  * :call s:StopJob()
        autocmd InsertChange * :call s:NotifyInsertChange()
        autocmd InsertLeave  * :call s:NotifyInsertLeave()

        autocmd CursorMovedI  * :call s:NotifyCursorMovedI()

    augroup END
endfunction



function! s:NotifyCursorMovedI()
    let [ buffnum, lnum, column, off ] = getpos('.')
    call rpcnotify(s:jobid, 'cursor-moved-i', lnum, column)
endfunction


function! s:NotifyInsertChange()

    let [ buffnum, lnum, column, off ] = getpos('.')
    call rpcnotify(s:jobid, 'insert-change',v:insertmode, lnum, column)
endfunction

function! s:NotifyInsertEnter()

    let [ buffnum, lnum, column, off ] = getpos('.')
    call rpcnotify(s:jobid, 'insert-change', v:insertmode ,lnum, column)
endfunction

function! s:NotifyInsertLeave()

    call rpcnotify(s:jobid, 'insert-leave')
endfunction

function! s:OnStderr()
    echom 'telearena: std: ' . join(a:data, "\n")
    call rpcnotify(s:jobid, 'insert-leave')
endfunction


function! s:StartJob()
  if 0 == s:jobid
    let id = jobstart([s:bin], { 'rpc': v:true, 'on_stderr': function('s:OnStderr') })
    return id
  else
    return 0
  endif
endfunction

function! s:StopJob()
  if 0 < s:jobid
    augroup scortchedEarth
      autocmd!    " clear all previous autocommands
    augroup END

    call rpcnotify(s:jobid, 'quit')
    let result = jobwait(s:jobid, 500)

    if -1 == result
      " kill the job
      call jobstop(s:jobid)
    endif

    " reset job id back to zero
    let s:jobid = 0
  endif
endfunction 
