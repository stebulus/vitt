nnoremap -n :call NewTask()<cr>
nnoremap -N :call NewTaskExclusiveRunning()<cr>
nnoremap -w :call SetTaskState("waiting")<cr>
nnoremap -r :call SetTaskState("running")<cr>
nnoremap -R :call SetTaskExclusiveRunning()<cr>
nnoremap -d :call SetTaskState("done")<cr>

inoremap DD <esc>:execute "normal! a" . strftime("%F", localtime())<cr>a
