from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from .config import Config  # 注意用相对导入（.config 表示当前 app 包下的 config.py）

# 初始化数据库
db = SQLAlchemy()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)  # 加载配置
    
    # 初始化插件
    db.init_app(app)
    CORS(app)
    
    # 注册蓝图（示例，根据实际路由调整）
    from .routes.auth import auth_bp  # 相对导入：从当前 app 包的 routes 目录导入 auth_bp
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    
    # 创建数据库表（生产环境建议移到单独脚本，避免重复创建）
    with app.app_context():
        db.create_all()
    
    return app