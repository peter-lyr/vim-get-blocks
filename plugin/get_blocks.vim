function! InitCodeBlock()
    python3 << EOF
import vim
file_path = vim.eval("expand('%:p')")
line_num = vim.eval("line('.')")

with open(file_path) as f:
    lines = f.readlines()

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

function! CopyCodeBlock()
    call InitCodeBlock()
    python3 << EOF
if 'not_ok' in locals():
    del not_ok
else:
    vim.eval(f'''setreg('"', {code_lines})''')
    del up_num, down_num, code_lines, line_num
EOF
endfunction

function! SelectCodeBlock()
    call InitCodeBlock()
    exec 'normal zn'
    python3 << EOF
if 'not_ok' in locals():
    del not_ok
else:
    m1 = f'{up_num-1}k' if up_num > 1 else ''
    m2 = f'{down_num+up_num-1}j' if down_num+up_num-1 > 0 else ''
    if len(code_lines):
        vim.command(f'''normal {m1}V{m2}''')
    del up_num, down_num, code_lines, line_num, m1, m2
EOF
    exec 'normal zbjk'
endfunction

function! DeleteCodeBlock()
    call SelectCodeBlock()
    exec 'normal d'
endfunction

nnoremap <silent> yib :call CopyCodeBlock()<cr>
nnoremap <silent> vib :call SelectCodeBlock()<cr>
nnoremap <silent> dib :call DeleteCodeBlock()<cr>
