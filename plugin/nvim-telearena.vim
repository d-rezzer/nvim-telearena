"Tele-arena srcipt interface of awesomeness!
function! Tahello()
    echo "You are in the north plaza \n"
endfunction

lua << EOF
    function luahello()
        print(tostring(vim.api.nvim_get_current_line()))
    end
EOF
       
command! SayHelloTa :lua luahello()
nnoremap <localleader>st :SayHelloTa<CR>


"Initialize rpc channel
if !exists('s:calculatorJobId')
    let s:calculatorJobId = 0
endif

" The path to the binary that was created out of cargo build or cargo build
" --release
let s:scriptdir = resolve(expand('<sfile>:p:h') . '/..')
let s:bin = '/target/debug/nvim-telearena'

" entry point. Initialize RPC. if success then attach commands to 
" the rpcnotify invocation. 

function! s:connect()
    let id = s:initRpc()

    if 0 == id
        echoerr "Calculator: cannot start rpc process."
    elseif -1 == id
        echoerr "Calculator: rpc process is not executable"
    else
        "mutate our old jobId variable to hold the channel ID
        let s:calculatorJobId = id

        call s:configureCommands()
    endif

endfunction


"initializ rpc
function! s:initRpc()
    if s:calculatorJobId == 0
        let jobid = jobstart([s:bin], {'rpc', v:true})
        return jobid
    else
        return s:calculatorJobId

    endif
endfunction


function! s:configureCommands()
    command! -nargs=+ Add :call s:add()
    command! -nargs=+ Multiply :call s:multiply(<f-args>)

endfunction

"Constants for RPC messages
let s:Add = 'add'
let s:Multiply = 'multiply'


function! s:add()
    let s:p = '1'

    let s:q = '2'
    echo "sup"

    call rpcnotify(s:calculatorJobId, s:Add, str2nr(s:p), str2nr(s:q))
endfunction


function! s:multiply(...)

    let s:p = get(a:, 1, 1)
    let s:q = get(a:, 2, 1)

    call rpcnotify(s:calculatorJobId, s:Multiply, str2nr(s:p), str2nr(s:q))
endfunction


