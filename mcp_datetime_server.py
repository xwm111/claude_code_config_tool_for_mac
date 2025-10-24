#!/usr/bin/env python3
"""
MCP服务器：提供日期时间相关功能
"""

import json
import sys
import datetime
from typing import Dict, Any


def get_current_time() -> Dict[str, Any]:
    """获取当前时间信息"""
    now = datetime.datetime.now()
    return {
        "current_time": now.isoformat(),
        "timestamp": int(now.timestamp()),
        "formatted": {
            "date": now.strftime("%Y-%m-%d"),
            "time": now.strftime("%H:%M:%S"),
            "datetime": now.strftime("%Y-%m-%d %H:%M:%S"),
            "iso": now.isoformat(),
            "utc": datetime.datetime.now(datetime.timezone.utc).isoformat()
        }
    }


def format_time(timestamp: int, format_str: str = "%Y-%m-%d %H:%M:%S") -> str:
    """格式化时间戳"""
    dt = datetime.datetime.fromtimestamp(timestamp)
    return dt.strftime(format_str)


def send_response(response: Dict[str, Any]):
    """发送JSON-RPC响应"""
    print(json.dumps(response, ensure_ascii=False))
    sys.stdout.flush()


def handle_initialize(request: Dict[str, Any]) -> Dict[str, Any]:
    """处理初始化请求"""
    return {
        "jsonrpc": "2.0",
        "id": request.get("id"),
        "result": {
            "protocolVersion": "2024-11-05",
            "capabilities": {
                "tools": {}
            },
            "serverInfo": {
                "name": "datetime-server",
                "version": "1.0.0"
            }
        }
    }


def handle_tools_list(request: Dict[str, Any]) -> Dict[str, Any]:
    """处理工具列表请求"""
    return {
        "jsonrpc": "2.0",
        "id": request.get("id"),
        "result": {
            "tools": [
                {
                    "name": "get_current_time",
                    "description": "获取当前时间的详细信息，包括多种格式",
                    "inputSchema": {
                        "type": "object",
                        "properties": {},
                        "required": []
                    }
                }
            ]
        }
    }


def handle_tools_call(request: Dict[str, Any]) -> Dict[str, Any]:
    """处理工具调用请求"""
    params = request.get("params", {})
    tool_name = params.get("name")
    arguments = params.get("arguments", {})

    if tool_name == "get_current_time":
        result = get_current_time()
        return {
            "jsonrpc": "2.0",
            "id": request.get("id"),
            "result": {
                "content": [{
                    "type": "text",
                    "text": json.dumps(result, indent=2, ensure_ascii=False)
                }]
            }
        }
    else:
        return {
            "jsonrpc": "2.0",
            "id": request.get("id"),
            "error": {
                "code": -32601,
                "message": f"Unknown tool: {tool_name}"
            }
        }


def main():
    """MCP服务器主函数"""
    try:
        while True:
            # 读取来自STDIN的JSON-RPC请求
            line = sys.stdin.readline()
            if not line:
                break

            try:
                request = json.loads(line.strip())
            except json.JSONDecodeError:
                continue

            method = request.get("method")

            # 处理不同的方法调用
            if method == "initialize":
                response = handle_initialize(request)
            elif method == "tools/list":
                response = handle_tools_list(request)
            elif method == "tools/call":
                response = handle_tools_call(request)
            else:
                response = {
                    "jsonrpc": "2.0",
                    "id": request.get("id"),
                    "error": {
                        "code": -32601,
                        "message": f"Method not found: {method}"
                    }
                }

            # 输出响应
            send_response(response)

    except Exception as e:
        error_response = {
            "jsonrpc": "2.0",
            "id": request.get("id") if 'request' in locals() else None,
            "error": {
                "code": -32603,
                "message": f"Internal error: {str(e)}"
            }
        }
        send_response(error_response)


if __name__ == "__main__":
    main()