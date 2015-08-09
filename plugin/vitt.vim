function! NewTask()
  let logstart = s:LogStart_SmashPos()
  call s:TryCursor(logstart, 1)
  let n = search('^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d[-+]\d\d\d\d' . "\t" . '\d\+' . "\tnew\t-$", 'W')
  if n == 0
    let nextid = 1
  else
    let line = getline(n)
    let i = matchend(line, "\t")
    let nextid = 1 + s:TaskAttr('id', s:ParseTask(strpart(line, i)))
  endif
  let newtask = nextid . "\tnew\t-"
  call s:TryAppend(0, newtask)
  call s:TryCursor(1, 1)
  execute "normal! $"
  call s:Log(getline('.'))
  return nextid
endfunction

function! SetTaskState(newstate)
  call s:SavePosInTask(function("s:SetTaskState_SmashPos"), a:newstate)
endfunction

function! ReplaceTaskState(from, to)
  call s:SavePosInTask(function("s:ReplaceTaskState_SmashPos"), a:from, a:to)
endfunction

function! s:SetTaskState_SmashPos(newstate)
  let task = s:ParseTask(getline('.'))
  let line = task.line
  let idx = task.stateidx
  let newline = strpart(line, 0, idx[0]) . a:newstate . strpart(line, idx[1])
  call setline('.', newline)
  call s:Log_SmashPos(newline)
endfunction

function! s:ReplaceTaskState_SmashPos(from, to)
  if a:from ==# s:TaskAttr('state', s:ParseTask(getline('.')))
    call s:SetTaskState_SmashPos(a:to)
  fi
endfunction

function! s:ParseTask(line)
  let d = {'line': a:line}
  let d.ididx = [0, matchend(a:line, '^\S*')]
  let d.stateidx = [match(a:line, '\S\+', d.ididx[1]), matchend(a:line, '\S\+', d.ididx[1])]
  let d.taskidx = [match(a:line, '\S', d.stateidx[1]), strlen(a:line)]
  return d
endfunction

function! s:TaskAttr(attr, task)
  let idx = a:task[a:attr . 'idx']
  return strpart(a:task.line, idx[0], idx[1]-idx[0])
endfunction

function! s:SavePos(fn, ...)
  let pos = getpos('.')
  try
    return call(a:fn, a:000)
  finally
    call setpos('.', pos)
  endtry
endfunction

function! s:SavePosInTask(...)
  let olddescstart = s:ParseTask(getline('.')).taskidx[0]
  let c = col('.')
  if c < olddescstart
    call call("s:SavePos", a:000)
  else
    call s:TryCursor(0, 1)
    call call("s:SavePos", a:000)
    let newdescstart = s:ParseTask(getline('.')).taskidx[0]
    call s:TryCursor(0, c - olddescstart + newdescstart)
  endif
endfunction

function! s:Log(line)
  call s:SavePos(function("s:Log_SmashPos"), a:line)
endfunction

function! s:Log_SmashPos(line)
  let logstart = s:LogStart_SmashPos()
  call s:TryAppend(logstart, s:ISOTime() . "\t" . a:line)
endfunction

function! s:LogStart_SmashPos()
  call s:TryCursor(1, 1)
  let logstart = search('^-- log$', 'W')
  if logstart == 0
    call s:TryAppend(line('$'), '')
    call s:TryAppend(line('$'), '-- log')
    let logstart = line('$')
  endif
  return logstart
endfunction

function! s:TryAppend(lnum, expr)
  let failed = append(a:lnum, a:expr)
  if failed
    throw "could not append " . a:expr . " after line " . a:lnum
  endif
endfunction

function! s:TryCursor(lnum, col)
  let failed = cursor(a:lnum, a:col)
  if failed
    throw "could not move cursor to (" . a:lnum . "," . a:col . ")"
  endif
endfunction

function! s:ISOTime()
  return strftime("%FT%T%z", localtime())
endfunction
