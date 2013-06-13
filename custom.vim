nnoremap <C-f> :Gtags <C-r><C-w><CR>
nnoremap <C-g> :Gtags -r <C-r><C-w><CR>

cnoremap <silent> ff<CR> <C-u>Unite -buffer-name=files bookmark file<CR>
cnoremap <silent> fm<CR> <C-u>Unite -buffer-name=mru-files file_mru<CR>
