# run.py
import sys  # 导入sys模块
import os
from app import create_app 


sys.path.append(os.path.dirname(os.path.abspath(__file__)))
app = create_app()
if __name__ == "__main__":
    # 基础配置：启动服务器，默认端口 5000，仅本地可访问
    app.run(
        debug=True,        # 开启调试模式（代码修改后自动重启，错误时显示调试页面）
        host='0.0.0.0',    # 允许外部访问（如同一局域网内的设备）
        port=5000       # 自定义端口（默认 5000，可改为 8080、8888 等）
    )