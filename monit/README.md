一些monit实用脚本

# amonit
用法：
```bash
amonit [进程名的一部分/pid]
```
将ps -ef下所有符合该进程名（或PID）的进程进入到monit监控中。
注：不支持正则表达式

# damonit
用法：
```bash
damonit
```
取消监控所有进程

# dmonit
用法：
```bash
dmonit [监控名]
```
将指定监控名的从列表中去除

# nmonit
用法：
```bash
nmonit [进程名]
```
监控指定的进程名匹配的第一个进程（monit自带功能）

# pmonit
用法：
```bash
pmonit [监控名] [pid]
```
指定监控名，监控某个pid的进程。