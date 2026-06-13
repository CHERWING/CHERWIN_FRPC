import re

with open('CHERWIN_FRPC/webroot/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

if '低电量' not in content:
    count = 0
    def replace_second(m):
        global count
        count += 1
        if count == 2:
            battery = '<div style="margin-top: 10px; font-size: 11px; color: #888; text-align: center;">\n                    🔋 已启用低电量保护：电量 &lt; 20% 且未充电时，进程将自动停止以保护电池。\n                </div>'
            return battery + '\n            </div>\n\n            <div class="card">'
        return m.group(0)

    new_content = re.sub(r'</div>\n\n            <div class="card">', replace_second, content, count=2)

    with open('CHERWIN_FRPC/webroot/index.html', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print('Battery notice added successfully')
else:
    print('Battery notice already exists')
