# MCP日期时间工具使用说明

## 概述
本项目包含一个自定义的MCP（Model Context Protocol）服务器，用于提供日期时间相关功能。

## 安装和配置

### 1. MCP服务器文件
- 位置：`mcp_datetime_server.py`
- 功能：提供当前时间获取、时间戳转换等日期时间服务

### 2. Claude配置文件
- 位置：`~/.config/claude/claude_desktop_config.json`
- 配置内容：
```json
{
  "mcpServers": {
    "datetime": {
      "command": "python3",
      "args": ["/Users/weimingxu/Documents/AI/claude_code_config_tool/mcp_datetime_server.py"]
    }
  }
}
```

## 使用方法

### 重启Claude应用
在修改配置后，需要重启Claude应用以加载新的MCP服务器。

### 调用时间工具
重启后，可以使用以下方式获取当前时间：
```
请使用datetime工具获取当前时间
```

## 可用功能

### get_current_time
获取当前时间的详细信息，包括：
- ISO格式时间戳
- Unix时间戳
- 格式化的日期、时间、日期时间
- UTC时间

### 返回格式示例
```json
{
  "current_time": "2025-10-23T03:15:30.123456",
  "timestamp": 1729677330,
  "formatted": {
    "date": "2025-10-23",
    "time": "03:15:30",
    "datetime": "2025-10-23 03:15:30",
    "iso": "2025-10-23T03:15:30.123456",
    "utc": "2025-10-23T03:15:30.123456Z"
  }
}
```

## 故障排除

### 1. MCP服务器未加载
- 确认Claude应用已重启
- 检查配置文件路径是否正确
- 确认Python3已安装并可执行

### 2. 权限问题
```bash
chmod +x mcp_datetime_server.py
```

### 3. Python依赖
确保系统安装了Python 3：
```bash
python3 --version
```

## 扩展功能
可以在`mcp_datetime_server.py`中添加更多日期时间相关功能，如：
- 时区转换
- 时间格式化
- 日期计算
- 定时器功能