function! InitCodeBlock()
    "python代码入口
    python3 << EOF
import vim # 导入接口
file_path = vim.eval("expand('%:p')") # 获取当前文件路径
if not file_path: # 判断是否已命名文件
    file_path = vim.eval('g:tmp_root ."untitled_" .strftime("%Y-%m-%d_%H%M%S") .".md"') # 定义临时文件存储路径
    vim.command(f'w! {file_path}') # 写入临时文件

line_num = vim.eval("line('.')") # 获取光标所在行号
with open(file_path) as f: # 打开当前文件
    lines = f.readlines() # 将每行文本存入列表中

if '```' == lines[int(line_num)-1][:3]:
    del lines, f, file_path
    not_ok = True
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
            break
    up_num = len(lines_11)

    lines_22 = []
    for i in lines_2:
        if '```' not in i:
            lines_22.append(i)
        else:
            break
    down_num = len(lines_22)

    code_lines = lines_11[::-1] + lines_22
    del lines_11, lines_22, lines_1, lines, f, lines_2, i, file_path
EOF
endfunction

function! CopyCodeBlock(mode)
    call InitCodeBlock()
    python3 << EOF
import vim
mode = vim.eval('a:mode')
if 'not_ok' in locals():
    del not_ok
else:
    if mode == 'i':
        vim.command(f'{int(line_num)-int(up_num)+1},{int(line_num)+int(down_num)}y')
    elif mode == 'a':
        vim.command(f'{int(line_num)-int(up_num)},{int(line_num)+int(down_num)+1}y')
    del up_num, down_num, code_lines, line_num, mode, block_head
EOF
endfunction

function! SelectCodeBlock(mode)
    call InitCodeBlock()
    exec 'normal zn'
    python3 << EOF
import vim
mode = vim.eval('a:mode')
if 'not_ok' in locals():
    del not_ok
else:
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

function! DeleteCodeBlock(mode)
    call SelectCodeBlock(a:mode)
    exec 'normal d'
endfunction

function! ChangeCodeBlock(mode)
    call SelectCodeBlock(a:mode)
    exec 'normal c'
endfunction

nnoremap <silent> yib :call CopyCodeBlock('i')<cr>
nnoremap <silent> vib :call SelectCodeBlock('i')<cr>
nnoremap <silent> dib :call DeleteCodeBlock('i')<cr>
nnoremap <silent> cib :call ChangeCodeBlock('i')<cr>

nnoremap <silent> yab :call CopyCodeBlock('a')<cr>
nnoremap <silent> vab :call SelectCodeBlock('a')<cr>
nnoremap <silent> dab :call DeleteCodeBlock('a')<cr>
nnoremap <silent> cab :call ChangeCodeBlock('a')<cr>
