# Terminal Tools Cheatsheet

> 快速上手指南 — 每个工具列出日常最高频的命令/快捷键

---

## 经典命令替代

### bat (替代 cat)
```
bat file.py              # 语法高亮 + 行号
bat -r 10:20 file.py     # 只看第 10-20 行
bat -l json file.txt     # 强制指定语言高亮
bat --diff file1 file2   # 两文件对比
bat -p file.py           # 纯输出 (适合管道)
bat -A file.py           # 显示不可见字符
```

### eza (替代 ls)
```
eza -la                  # 长列表 + 隐藏文件
eza -l --git             # 显示 Git 状态列
eza --tree --level=2     # 树状视图，2 层深
eza -l --sort=modified   # 按修改时间排序
eza --icons -la          # 带文件图标
eza -l --group-directories-first  # 目录优先
```

### fd (替代 find)
```
fd pattern               # 递归模糊查找
fd -e py                 # 找所有 .py 文件
fd -e py -x wc -l        # 找 .py 并对每个执行 wc -l
fd -t d src              # 只找目录
fd -H pattern            # 包含隐藏文件
fd -e log --changed-within 1d   # 最近 24h 修改的文件
fd pattern --exclude node_modules  # 排除目录
```

### ripgrep / rg (替代 grep)
```
rg pattern               # 递归搜索 (自动忽略 .gitignore)
rg -i pattern            # 忽略大小写
rg -l pattern            # 只列文件名
rg -C 3 pattern          # 显示前后 3 行上下文
rg -t py pattern         # 只搜 Python 文件
rg -w word               # 全词匹配
rg -g '!test/**' pattern # 排除 test 目录
```

### sd (替代 sed)
```
sd 'old' 'new' file.txt        # 就地替换
echo 'hello' | sd 'hello' 'world'  # stdin 替换
sd 'foo(\d+)' 'bar$1' file     # 正则 + 捕获组
sd -s 'literal.str' 'new' file # 字面量模式 (不用转义)
sd '\n' ', ' file.txt           # 换行替换为逗号
```
> 与 sed 的区别：用标准正则语法，不需要转义 `()` `+` 等

### zoxide (替代 cd)
```
z foo                    # 跳到匹配 "foo" 的最高分目录
z foo bar                # 匹配 foo 和 bar
zi foo                   # 交互式选择 (结合 fzf)
z -                      # 跳回上一个目录
zoxide query -ls         # 列出所有记录的目录及分数
```

---

## 模糊搜索 & 导航

### fzf
```
fzf                      # 交互式模糊文件选择
Ctrl+T                   # 将选中文件路径粘贴到当前命令
Ctrl+R                   # 模糊搜索命令历史
Alt+C                    # 模糊 cd 到子目录
fzf --preview 'bat --color=always {}'  # 带语法高亮预览
```
**组合技：**
```
fd -e py | fzf --preview 'bat --color=always {}'  # 模糊选 py 文件 + 预览
rg -l 'TODO' | fzf      # 从含 TODO 的文件中选择
git log --oneline | fzf  # 模糊搜索 Git commit
```

### broot
```
br                       # 启动 (别名, 退出时可 cd)
输入即搜索                # 边打字边模糊过滤
Enter                    # 打开文件 / 进入目录
Alt+Enter                # 退出时 cd 到选中目录
:e                       # 用 $EDITOR 编辑选中文件
:cp dest / :mv dest      # 复制 / 移动文件
:total_size              # 显示树中每项大小
Ctrl+Q                   # 退出
```

---

## TUI 工具

### yazi (文件管理器)
```
h / l                    # 返回上级 / 进入目录(打开文件)
j / k                    # 上下移动
Space                    # 选中/取消选中
d                        # 剪切选中文件
y                        # 复制选中文件
p                        # 粘贴
r                        # 重命名
a                        # 新建文件 (末尾加 / 为目录)
/                        # 搜索
z                        # zoxide 跳转
.                        # 显示/隐藏 隐藏文件
q                        # 退出
```
> **y→z 工作流**: yazi 内按 `z` 跳转 → 退出后 zoxide 记住路径 → 下次 `z` 直接到

### lazygit (Git TUI)
```
1-5                      # 切换面板: Status/Files/Branches/Commits/Stash
Space                    # Stage/Unstage 文件
a                        # Stage/Unstage 全部
c                        # 提交
p                        # Push
P (Shift)                # Pull
Enter                    # 查看 diff / 展开
b                        # 分支切换菜单
d                        # 丢弃更改 (小心!)
/                        # 搜索
? 或 x                   # 显示快捷键帮助
q                        # 退出
```

### bottom / btm (系统监控)
```
btm                      # 启动
e / d                    # 展开 / 收缩选中组件
h / l                    # 左右切换组件焦点
j / k                    # 列表上下滚动
/ 然后输入               # 过滤进程
dd                       # Kill 选中进程
Tab                      # 循环切换组件
q 或 Ctrl+C              # 退出
btm --basic              # 简化模式启动
```

---

## 终端美化

### starship (Prompt 美化)
```
starship init bash       # 加到 .bashrc
starship init zsh        # 加到 .zshrc
starship preset nerd-font-symbols -o ~/.config/starship.toml  # 应用预设
starship explain         # 解释当前 prompt 每个段的含义
starship timings         # 显示每个模块渲染耗时
```
> 配置: `~/.config/starship.toml`，常用段: `[git_branch]`, `[nodejs]`, `[python]`, `[directory]`

---

## 文档 & 查询

### glow (Markdown 渲染)
```
glow file.md             # 渲染 Markdown
glow -p file.md          # 分页滚动模式
glow -w 80 file.md       # 限制宽度 80 列
glow                     # 交互式浏览本地 .md 文件
cat file.md | glow -     # 从 stdin 渲染
```

### tldr (man 替代)
```
tldr tar                 # 查看 tar 实用示例
tldr git commit          # 支持子命令
tldr -u                  # 更新本地缓存
tldr -l                  # 列出所有可用页面
```

---

## 系统工具

### dust (替代 du)
```
dust                     # 当前目录磁盘用量 (可视化柱状图)
dust -n 10               # 只显示前 10 项
dust -d 2                # 限制 2 层深度
dust /path               # 分析指定目录
dust -i node_modules     # 忽略特定目录
```

### procs (替代 ps)
```
procs                    # 彩色进程列表
procs node               # 过滤含 "node" 的进程
procs --tree             # 进程树
procs --sortd cpu        # 按 CPU 降序
procs --sortd mem        # 按内存降序
procs -w                 # 实时刷新模式
```

### xh (HTTP 客户端, 替代 curl/httpie)
```
xh httpbin.org/get                # GET 请求 (格式化输出)
xh POST api.com/data key=value   # POST JSON (自动序列化)
xh -f POST api.com/form name=v   # POST 表单数据
xh -b url                        # 只输出 body
xh -h url                        # 只输出 headers
xh -d url                        # 下载文件
xh url Authorization:Bearer\ tok # 自定义 header
```

---

## 高效组合技

```bash
# 模糊选 Python 文件并预览
fd -e py | fzf --preview 'bat --color=always {}'

# 从含 TODO 的文件中交互选择
rg -l 'TODO' | fzf

# 模糊搜索 Git commit
git log --oneline | fzf

# 交互式选进程并 kill
kill -9 $(procs | fzf | awk '{print $1}')

# 彩色磁盘用量
dust -d 1 | bat -l log
```

---

*Created: 2026-03-20 | 工具均通过 scoop 安装*
