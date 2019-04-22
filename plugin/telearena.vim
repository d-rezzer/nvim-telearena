"Tele-arena srcipt interface of awesomeness!
function! Tahello()
    echo "You are in the north plaza \n"
endfunction

function! TaWhere()
    echo "You are in the SOUTH plaza \n"
endfunction


lua << EOF
    function luahello()
        print(tostring(vim.api.nvim_get_current_line()))
    end
EOF
       
command! SayHelloTa :lua luahello()
nnoremap <localleader>st :SayHelloTa<CR>

command! -nargs=0 TeleArenaConnect call telearena#connect()
