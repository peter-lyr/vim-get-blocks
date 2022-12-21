let s:temp = $HOMEDRIVE .$HOMEPATH .'\temps'

if !isdirectory(s:temp)
  call system(printf('mkdir %s', s:temp))
endif

function! s:init()
  if len(nvim_buf_get_name(0)) == 0
    exec printf('w! %s\tmp.md', s:temp)
  endif
  python3 << EOF
import vim # 导入接口
file_path = vim.eval("expand('%:p')") # 获取当前文件路径

line_num = vim.eval("line('.')") # 获取光标所在行号
with open(file_path, 'rb') as f: # 打开当前文件
  lines = f.readlines() # 将每行文本存入列表中
lines = [line.decode('utf-8') for line in lines]

not_ok = True
if '```' == lines[int(line_num)-1][:3]:
  del lines, f, file_path
else:
  lines_1, lines_2 = [], []
  for i in range(len(lines)):
    if i < int(line_num):
      lines_1.append(lines[i].rstrip())
    else:
      lines_2.append(lines[i].rstrip())

  lines_11 = []
  for i in lines_1[::-1]:
    if f'```' != i[:3]:
      lines_11.append(i)
    else:
      file_type = i.lstrip()[3:]
      vim.command(f'let g:file_type = "{file_type}"')
      block_head = i
      not_ok = False
      break
  up_num = len(lines_11)

  lines_22 = []
  for i in lines_2:
    if '```' not in i:
      lines_22.append(i)
    else:
      not_ok = False
      break
  down_num = len(lines_22)

  code_lines = lines_11[::-1] + lines_22
  del lines_11, lines_22, lines_1, lines, f, lines_2, i, file_path
vim.command(f'let not_ok = "{not_ok}"')
EOF
  if exists('not_ok') && not_ok == 'True'
    return 'not_ok'
  else
    return 'ok'
  endif
endfunction

function! getblocks#copy(mode)
  let status = s:init()
  if status == 'not_ok'
    return
  endif
  python3 << EOF
import vim
mode = vim.eval('a:mode')
if mode == 'i':
  vim.command(f'{int(line_num)-int(up_num)+1},{int(line_num)+int(down_num)}y')
elif mode == 'a':
  vim.command(f'{int(line_num)-int(up_num)},{int(line_num)+int(down_num)+1}y')
del up_num, down_num, code_lines, line_num, mode, block_head
EOF
endfunction

function! getblocks#select(mode)
  let status = s:init()
  if status == 'not_ok'
    return
  endif
  exec 'normal zn'
  python3 << EOF
import vim
mode = vim.eval('a:mode')
if mode == 'a':
  up_num += 1
  down_num += 1
m1 = f'{up_num-1}k' if up_num > 1 else ''
m2 = f'{down_num+up_num-1}j' if down_num+up_num-1 > 0 else ''
if len(code_lines):
  vim.command(f'''normal {m1}V{m2}''')
del up_num, down_num, code_lines, line_num, m1, m2, mode, block_head, file_type
EOF
  "exec 'normal zbjk'
endfunction

function! getblocks#delete(mode)
  call getblocks#select(a:mode)
  exec 'normal d'
endfunction

function! getblocks#change(mode)
  call getblocks#select(a:mode)
  exec 'normal c'
endfunction

